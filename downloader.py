#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ============================================
# IMPORTS - MUST BE AT THE TOP
# ============================================
try:
    import aiohttp
    import aiofiles
    import asyncio
    import json
    import os
    import re
    import random
    import ssl
    from datetime import datetime
    from urllib.parse import quote, urlparse
    from typing import Optional, Dict, Tuple, List
    from colorama import init, Fore, Style
except ImportError as e:
    print(f"Missing required package: {e}")
    print("Install with: pip install aiohttp aiofiles colorama")
    exit(1)

# Initialize colorama
init(autoreset=True)

# ============================================
# CONFIGURATION
# ============================================
DOWNLOAD_FOLDER = 'downloads'
PROXY_FILE = 'proxy.txt'
LOG_FILE = 'download_log.json'
MODRINTH_API = "https://api.modrinth.com/v2"

# Global variables
PROXY_POOL = []
USED_PROXIES_PER_PROJECT = {}
FAILED_PROXIES = set()

# ============================================
# ASCII ART
# ============================================
def print_banner():
    banner = """
    ███╗   ███╗ ██████╗ ██████╗ ██████╗ ██╗███╗   ██╗████████╗██╗  ██╗
    ████╗ ████║██╔═══██╗██╔══██╗██╔══██╗██║████╗  ██║╚══██╔══╝██║  ██║
    ██╔████╔██║██║   ██║██║  ██║██████╔╝██║██╔██╗ ██║   ██║   ███████║
    ██║╚██╔╝██║██║   ██║██║  ██║██╔══██╗██║██║╚██╗██║   ██║   ██╔══██║
    ██║ ╚═╝ ██║╚██████╔╝██████╔╝██║  ██║██║██║ ╚████║   ██║   ██║  ██║
    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝
    
    ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗      ██████╗  █████╗ ██████╗ ███████╗██████╗ 
    ██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
    ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║███████║██║  ██║█████╗  ██████╔╝
    ██║  ██║██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║██╔══██║██║  ██║██╔══╝  ██╔══██╗
    ██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝██║  ██║██████╔╝███████╗██║  ██║
    ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝
    """
    
    lines = banner.strip().split('\n')
    terminal_width = 120
    try:
        terminal_width = os.get_terminal_size().columns
    except:
        pass
    
    for line in lines:
        padding = (terminal_width - len(line)) // 2
        print(Fore.CYAN + " " * max(0, padding) + line)
    
    print(Fore.YELLOW + Style.BRIGHT + "\n" + "="*terminal_width)
    print(Fore.GREEN + Style.BRIGHT + "PROXY-BASED MODRINTH DOWNLOADER".center(terminal_width))
    print(Fore.YELLOW + Style.BRIGHT + "="*terminal_width + "\n")

# ============================================
# UTILITY FUNCTIONS
# ============================================
def load_logs() -> List:
    if os.path.exists(LOG_FILE):
        try:
            with open(LOG_FILE, 'r') as f:
                return json.load(f)
        except:
            return []
    return []

def save_logs(logs: List):
    with open(LOG_FILE, 'w') as f:
        json.dump(logs, f, indent=4)

def ensure_download_folder() -> str:
    if not os.path.exists(DOWNLOAD_FOLDER):
        os.makedirs(DOWNLOAD_FOLDER)
    return DOWNLOAD_FOLDER

def get_plugin_folder(plugin_name: str) -> str:
    clean_name = re.sub(r'[<>:"/\\|?*]', '', plugin_name)
    plugin_folder = os.path.join(DOWNLOAD_FOLDER, clean_name)
    if not os.path.exists(plugin_folder):
        os.makedirs(plugin_folder)
    return plugin_folder

def generate_unique_filename(folder: str, base_filename: str, index: int = 0) -> Tuple[str, str]:
    if index == 0:
        test_name = base_filename
    else:
        name, ext = os.path.splitext(base_filename)
        test_name = f"{name}({index}){ext}"
    
    path = os.path.join(folder, test_name)
    
    if os.path.exists(path):
        return generate_unique_filename(folder, base_filename, index + 1)
    
    return test_name, path

# ============================================
# SSL CONTEXT HELPER
# ============================================
def create_ssl_context():
    """Create a permissive SSL context for proxy connections"""
    ssl_context = ssl.create_default_context()
    ssl_context.check_hostname = False
    ssl_context.verify_mode = ssl.CERT_NONE
    return ssl_context

# ============================================
# PROXY MANAGEMENT
# ============================================
def normalize_proxy(proxy: str) -> str:
    """Normalize proxy format"""
    proxy = proxy.strip()
    
    if proxy.startswith('http://'):
        proxy = proxy[7:]
    elif proxy.startswith('https://'):
        proxy = proxy[8:]
    elif proxy.startswith('socks5://'):
        return f"socks5://{proxy[9:]}"
    elif proxy.startswith('socks4://'):
        return f"socks4://{proxy[9:]}"
    
    return f"http://{proxy}"

def load_proxies_from_file() -> List[str]:
    """Load proxies from proxy.txt file"""
    proxies = []
    if os.path.exists(PROXY_FILE):
        try:
            with open(PROXY_FILE, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        normalized = normalize_proxy(line)
                        if normalized not in proxies:
                            proxies.append(normalized)
            print(Fore.GREEN + f"✅ Loaded {len(proxies)} proxies from {PROXY_FILE}")
        except Exception as e:
            print(Fore.RED + f"❌ Error loading proxies: {e}")
    else:
        print(Fore.YELLOW + f"⚠️  {PROXY_FILE} not found")
    return proxies

def save_proxies_to_file(proxies: List[str]):
    """Save proxies to proxy.txt file"""
    try:
        with open(PROXY_FILE, 'w') as f:
            for proxy in proxies:
                clean_proxy = proxy.replace('http://', '').replace('https://', '')
                f.write(f"{clean_proxy}\n")
        print(Fore.GREEN + f"✅ Saved {len(proxies)} proxies to {PROXY_FILE}")
    except Exception as e:
        print(Fore.RED + f"❌ Error saving proxies: {e}")

async def check_proxy(proxy: str, timeout_sec: int = 15) -> Tuple[bool, float]:
    """Check if a proxy is working"""
    test_urls = [
        "https://api.modrinth.com/v2",
        "http://ip-api.com/json",
        "https://httpbin.org/ip"
    ]
    
    start_time = asyncio.get_event_loop().time()
    ssl_ctx = create_ssl_context()
    
    for test_url in test_urls:
        try:
            timeout_obj = aiohttp.ClientTimeout(total=timeout_sec, connect=timeout_sec//2)
            connector = aiohttp.TCPConnector(
                ssl=ssl_ctx,
                limit=5,
                force_close=True,
                enable_cleanup_closed=True
            )
            
            async with aiohttp.ClientSession(
                connector=connector, 
                timeout=timeout_obj,
                trust_env=True
            ) as session:
                headers = {
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
                }
                async with session.get(
                    test_url, 
                    proxy=proxy,
                    headers=headers,
                    allow_redirects=True
                ) as response:
                    if response.status in [200, 204, 301, 302]:
                        elapsed = asyncio.get_event_loop().time() - start_time
                        return True, elapsed
        except:
            continue
    
    return False, 0.0

async def check_all_proxies(proxies: List[str], max_concurrent: int = 20) -> List[str]:
    """Check all proxies and return working ones"""
    print(Fore.CYAN + f"\n🔍 Checking {len(proxies)} proxies (max {max_concurrent} concurrent)...")
    
    working_proxies = []
    semaphore = asyncio.Semaphore(max_concurrent)
    
    async def check_with_semaphore(proxy, index):
        async with semaphore:
            is_working, response_time = await check_proxy(proxy)
            return proxy, index, is_working, response_time
    
    tasks = [check_with_semaphore(proxy, i) for i, proxy in enumerate(proxies)]
    
    for coro in asyncio.as_completed(tasks):
        proxy, index, is_working, response_time = await coro
        if is_working:
            working_proxies.append(proxy)
            print(Fore.GREEN + f"✅ Proxy {index+1}/{len(proxies)}: Working ({response_time:.2f}s) - {proxy[:50]}")
        else:
            print(Fore.RED + f"❌ Proxy {index+1}/{len(proxies)}: Failed - {proxy[:50]}")
    
    print(Fore.YELLOW + f"\n📊 Result: {len(working_proxies)}/{len(proxies)} proxies working")
    return working_proxies

async def generate_proxies(count: int) -> List[str]:
    """Generate proxies from free proxy APIs"""
    print(Fore.CYAN + f"\n🔄 Generating {count} proxies from free APIs...")
    
    proxies = set()
    ssl_ctx = create_ssl_context()
    
    sources = [
        ("https://api.proxyscrape.com/v2/?request=displayproxies&protocol=http&timeout=10000&country=all&ssl=all&anonymity=all", "ProxyScrape"),
        ("https://www.proxy-list.download/api/v1/get?type=http", "Proxy-List"),
        ("https://raw.githubusercontent.com/TheSpeedX/PROXY-List/master/http.txt", "GitHub-SpeedX"),
        ("https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list-raw.txt", "GitHub-ClarkeM"),
        ("https://raw.githubusercontent.com/monosans/proxy-list/main/proxies/http.txt", "GitHub-Monosans"),
    ]
    
    connector = aiohttp.TCPConnector(ssl=ssl_ctx)
    timeout = aiohttp.ClientTimeout(total=20)
    
    async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
        for url, name in sources:
            if len(proxies) >= count:
                break
            try:
                headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
                async with session.get(url, headers=headers) as response:
                    if response.status == 200:
                        text = await response.text()
                        for line in text.strip().split('\n'):
                            line = line.strip()
                            if line and ':' in line and len(proxies) < count:
                                match = re.search(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}:\d+)', line)
                                if match:
                                    proxies.add(f"http://{match.group(1)}")
                        print(Fore.GREEN + f"✅ Fetched from {name}, total: {len(proxies)}")
            except Exception as e:
                print(Fore.RED + f"❌ {name} error: {str(e)[:50]}")
    
    result = list(proxies)
    random.shuffle(result)
    return result[:count]

def input_proxies_manually() -> List[str]:
    """Manually input proxies"""
    print(Fore.CYAN + "\n📝 Enter proxies (format: ip:port or http://ip:port)")
    print(Fore.YELLOW + "Enter 'done' when finished, 'cancel' to abort:")
    
    proxies = []
    while True:
        proxy = input(Fore.WHITE + f"Proxy {len(proxies)+1}: ").strip()
        
        if proxy.lower() == 'done':
            break
        elif proxy.lower() == 'cancel':
            return []
        elif proxy:
            normalized = normalize_proxy(proxy)
            proxies.append(normalized)
            print(Fore.GREEN + f"✅ Added: {normalized}")
    
    return proxies

def get_unique_proxy_for_project(project_name: str) -> Optional[str]:
    """Get a unique proxy for project"""
    global PROXY_POOL, USED_PROXIES_PER_PROJECT, FAILED_PROXIES
    
    if not PROXY_POOL:
        return None
    
    available_proxies = [p for p in PROXY_POOL if p not in FAILED_PROXIES]
    
    if not available_proxies:
        FAILED_PROXIES.clear()
        available_proxies = PROXY_POOL.copy()
    
    if project_name not in USED_PROXIES_PER_PROJECT:
        USED_PROXIES_PER_PROJECT[project_name] = set()
    
    for proxy in available_proxies:
        if proxy not in USED_PROXIES_PER_PROJECT[project_name]:
            USED_PROXIES_PER_PROJECT[project_name].add(proxy)
            return proxy
    
    USED_PROXIES_PER_PROJECT[project_name].clear()
    
    if available_proxies:
        proxy = random.choice(available_proxies)
        USED_PROXIES_PER_PROJECT[project_name].add(proxy)
        return proxy
    
    return None

def mark_proxy_failed(proxy: str):
    """Mark a proxy as failed"""
    global FAILED_PROXIES
    FAILED_PROXIES.add(proxy)

# ============================================
# URL PARSER
# ============================================
def extract_project_info_from_url(url: str) -> Optional[Dict]:
    """Extract project info from Modrinth URL"""
    try:
        parsed = urlparse(url)
        
        if 'cdn.modrinth.com' in url:
            pattern = r'/data/([^/]+)/versions/([^/]+)/([^/]+\.(jar|zip|mrpack))'
            match = re.search(pattern, parsed.path)
            if match:
                return {
                    'type': 'direct',
                    'project_id': match.group(1),
                    'version_id': match.group(2),
                    'filename': match.group(3),
                    'url': url
                }
        
        if 'modrinth.com' in parsed.netloc:
            project_match = re.search(r'/(plugin|mod|resourcepack|datapack|shader)/([^/?&#]+)', parsed.path)
            if project_match:
                return {
                    'type': 'page',
                    'project_slug': project_match.group(2)
                }
    except:
        pass
    
    return None

# ============================================
# MODRINTH API
# ============================================
class ModrinthDownloader:
    
    @staticmethod
    async def fetch_project_info(project_id_or_slug: str) -> Optional[Dict]:
        ssl_ctx = create_ssl_context()
        connector = aiohttp.TCPConnector(ssl=ssl_ctx)
        timeout = aiohttp.ClientTimeout(total=30)
        
        async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
            url = f"{MODRINTH_API}/project/{quote(project_id_or_slug, safe='')}"
            headers = {"User-Agent": "Modrinth-Downloader/1.0"}
            
            try:
                async with session.get(url, headers=headers) as response:
                    if response.status == 200:
                        return await response.json()
            except Exception as e:
                print(Fore.RED + f"API Error: {e}")
            return None
    
    @staticmethod
    async def fetch_version_info(project_id: str, game_version: str = None, loader: str = None) -> Optional[Dict]:
        ssl_ctx = create_ssl_context()
        connector = aiohttp.TCPConnector(ssl=ssl_ctx)
        timeout = aiohttp.ClientTimeout(total=30)
        
        async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
            url = f"{MODRINTH_API}/project/{quote(project_id, safe='')}/version"
            
            params = {}
            if game_version:
                params["game_versions"] = f'["{game_version}"]'
            if loader:
                params["loaders"] = f'["{loader}"]'
            
            headers = {"User-Agent": "Modrinth-Downloader/1.0"}
            
            try:
                async with session.get(url, headers=headers, params=params) as response:
                    if response.status == 200:
                        versions = await response.json()
                        if versions:
                            return sorted(versions, key=lambda x: x.get('date_published', ''), reverse=True)[0]
            except Exception as e:
                print(Fore.RED + f"API Error: {e}")
            return None

# ============================================
# DOWNLOAD FUNCTION
# ============================================
async def download_file(url: str, filepath: str, proxy: str = None, max_retries: int = 3) -> Tuple[bool, str, int, str]:
    """Download file with proxy"""
    
    user_agents = [
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    ]
    
    if not proxy:
        return False, "No proxy available", 0, "No Proxy"
    
    last_error = "Unknown error"
    
    for attempt in range(max_retries):
        try:
            user_agent = random.choice(user_agents)
            ssl_ctx = create_ssl_context()
            
            timeout = aiohttp.ClientTimeout(
                total=180,
                connect=45,
                sock_read=60
            )
            
            connector = aiohttp.TCPConnector(
                ssl=ssl_ctx,
                limit=10,
                limit_per_host=5,
                force_close=True,
                enable_cleanup_closed=True,
                ttl_dns_cache=300
            )
            
            headers = {
                "User-Agent": user_agent,
                "Accept": "application/octet-stream, application/java-archive, */*",
                "Accept-Language": "en-US,en;q=0.9",
                "Accept-Encoding": "gzip, deflate",
                "Connection": "keep-alive",
                "Cache-Control": "no-cache",
                "Pragma": "no-cache"
            }
            
            await asyncio.sleep(random.uniform(0.5, 2.0))
            
            async with aiohttp.ClientSession(
                connector=connector, 
                timeout=timeout,
                trust_env=True
            ) as session:
                
                async with session.get(
                    url, 
                    headers=headers, 
                    proxy=proxy,
                    allow_redirects=True,
                    raise_for_status=False
                ) as response:
                    
                    if response.status == 200:
                        total_size = int(response.headers.get('content-length', 0))
                        
                        async with aiofiles.open(filepath, 'wb') as f:
                            downloaded = 0
                            async for chunk in response.content.iter_chunked(65536):
                                if chunk:
                                    await f.write(chunk)
                                    downloaded += len(chunk)
                        
                        actual_size = os.path.getsize(filepath)
                        
                        if total_size > 0 and actual_size < total_size * 0.95:
                            if os.path.exists(filepath):
                                os.remove(filepath)
                            last_error = f"Incomplete: {actual_size}/{total_size}"
                            continue
                        
                        return True, None, actual_size, proxy
                    
                    elif response.status == 403:
                        last_error = "403 Forbidden - Proxy blocked"
                        mark_proxy_failed(proxy)
                        return False, last_error, 0, proxy
                    
                    elif response.status == 407:
                        last_error = "407 Proxy Auth Required"
                        mark_proxy_failed(proxy)
                        return False, last_error, 0, proxy
                    
                    elif response.status == 429:
                        last_error = "429 Rate Limited"
                        await asyncio.sleep(5)
                        continue
                    
                    else:
                        last_error = f"HTTP {response.status}"
                        continue
                        
        except asyncio.TimeoutError:
            last_error = "Timeout"
            continue
            
        except aiohttp.ClientProxyConnectionError as e:
            last_error = f"Proxy connection failed: {str(e)[:30]}"
            mark_proxy_failed(proxy)
            return False, last_error, 0, proxy
            
        except aiohttp.ClientConnectorError as e:
            last_error = f"Connection error: {str(e)[:30]}"
            continue
            
        except aiohttp.ClientError as e:
            last_error = f"Client error: {str(e)[:30]}"
            continue
            
        except Exception as e:
            last_error = f"Error: {str(e)[:40]}"
            continue
        
        finally:
            if os.path.exists(filepath) and os.path.getsize(filepath) == 0:
                try:
                    os.remove(filepath)
                except:
                    pass
    
    return False, last_error, 0, proxy

# ============================================
# MENUS
# ============================================
async def proxy_menu():
    """Proxy management menu"""
    global PROXY_POOL, FAILED_PROXIES
    
    while True:
        print(Fore.CYAN + "\n" + "="*60)
        print(Fore.YELLOW + Style.BRIGHT + "PROXY MANAGEMENT".center(60))
        print(Fore.CYAN + "="*60)
        print(Fore.WHITE + f"Current proxies loaded: {Fore.GREEN}{len(PROXY_POOL)}")
        print(Fore.WHITE + f"Failed proxies (temp): {Fore.RED}{len(FAILED_PROXIES)}")
        print(Fore.CYAN + "\n1. " + Fore.WHITE + "Load proxies from file (proxy.txt)")
        print(Fore.CYAN + "2. " + Fore.WHITE + "Input proxies manually")
        print(Fore.CYAN + "3. " + Fore.WHITE + "Generate proxies (auto-fetch from APIs)")
        print(Fore.CYAN + "4. " + Fore.WHITE + "Check current proxies")
        print(Fore.CYAN + "5. " + Fore.WHITE + "View proxy status")
        print(Fore.CYAN + "6. " + Fore.WHITE + "Clear all proxies")
        print(Fore.CYAN + "7. " + Fore.WHITE + "Clear failed proxies cache")
        print(Fore.CYAN + "0. " + Fore.WHITE + "Back to main menu")
        
        choice = input(Fore.YELLOW + "\nChoice: " + Fore.WHITE).strip()
        
        if choice == '1':
            PROXY_POOL = load_proxies_from_file()
            FAILED_PROXIES.clear()
        
        elif choice == '2':
            new_proxies = input_proxies_manually()
            if new_proxies:
                PROXY_POOL.extend(new_proxies)
                save_proxies_to_file(PROXY_POOL)
                print(Fore.GREEN + f"✅ Added {len(new_proxies)} proxies")
        
        elif choice == '3':
            try:
                count = int(input(Fore.YELLOW + "How many proxies to generate? " + Fore.WHITE))
                generated = await generate_proxies(count)
                if generated:
                    verify = input(Fore.YELLOW + "Verify generated proxies? (y/n): " + Fore.WHITE).lower()
                    if verify == 'y':
                        generated = await check_all_proxies(generated)
                    
                    PROXY_POOL.extend(generated)
                    PROXY_POOL = list(dict.fromkeys(PROXY_POOL))
                    save_proxies_to_file(PROXY_POOL)
                    print(Fore.GREEN + f"✅ Total proxies: {len(PROXY_POOL)}")
            except ValueError:
                print(Fore.RED + "❌ Invalid number")
        
        elif choice == '4':
            if PROXY_POOL:
                working = await check_all_proxies(PROXY_POOL)
                PROXY_POOL = working
                FAILED_PROXIES.clear()
                if working:
                    save_proxies_to_file(working)
            else:
                print(Fore.RED + "❌ No proxies loaded")
        
        elif choice == '5':
            if PROXY_POOL:
                print(Fore.CYAN + f"\n📊 Total proxies: {len(PROXY_POOL)}")
                print(Fore.RED + f"📊 Failed (cached): {len(FAILED_PROXIES)}")
                print(Fore.GREEN + f"📊 Available: {len([p for p in PROXY_POOL if p not in FAILED_PROXIES])}")
                print(Fore.CYAN + "\nFirst 10 proxies:")
                for i, proxy in enumerate(PROXY_POOL[:10], 1):
                    status = Fore.RED + "[FAILED]" if proxy in FAILED_PROXIES else Fore.GREEN + "[OK]"
                    print(Fore.WHITE + f"{i}. {proxy} {status}")
                if len(PROXY_POOL) > 10:
                    print(Fore.YELLOW + f"... and {len(PROXY_POOL)-10} more")
            else:
                print(Fore.RED + "❌ No proxies loaded")
        
        elif choice == '6':
            confirm = input(Fore.RED + "Clear all proxies? (yes/no): " + Fore.WHITE).lower()
            if confirm == 'yes':
                PROXY_POOL = []
                USED_PROXIES_PER_PROJECT.clear()
                FAILED_PROXIES.clear()
                print(Fore.GREEN + "✅ All proxies cleared")
        
        elif choice == '7':
            FAILED_PROXIES.clear()
            print(Fore.GREEN + "✅ Failed proxies cache cleared")
        
        elif choice == '0':
            break

async def download_menu():
    """Download menu"""
    global PROXY_POOL, FAILED_PROXIES
    
    if not PROXY_POOL:
        print(Fore.RED + "\n❌ No proxies loaded! Please load proxies first.")
        input(Fore.YELLOW + "Press Enter to continue...")
        return
    
    available = len([p for p in PROXY_POOL if p not in FAILED_PROXIES])
    if available == 0:
        print(Fore.RED + "\n❌ All proxies have failed! Clear failed cache or load new proxies.")
        input(Fore.YELLOW + "Press Enter to continue...")
        return
    
    print(Fore.CYAN + "\n" + "="*60)
    print(Fore.YELLOW + Style.BRIGHT + "DOWNLOAD FROM MODRINTH".center(60))
    print(Fore.CYAN + "="*60)
    
    try:
        amount = int(input(Fore.YELLOW + "\nHow many copies to download? " + Fore.WHITE))
        if amount <= 0:
            print(Fore.RED + "❌ Invalid amount")
            return
    except ValueError:
        print(Fore.RED + "❌ Invalid number")
        return
    
    print(Fore.YELLOW + "\n💡 You can enter:")
    print(Fore.WHITE + "   • Direct CDN link: " + Fore.CYAN + "https://cdn.modrinth.com/data/.../file.jar")
    print(Fore.WHITE + "   • Project page URL: " + Fore.CYAN + "https://modrinth.com/plugin/vault")
    print(Fore.WHITE + "   • Project slug only: " + Fore.CYAN + "vault")
    user_input = input(Fore.YELLOW + "\nEnter input: " + Fore.WHITE).strip()
    if not user_input:
        print(Fore.RED + "❌ Input required")
        return
    
    download_url = None
    filename = None
    plugin_name = None
    
    if user_input.startswith('http'):
        url_info = extract_project_info_from_url(user_input)
        
        if not url_info:
            print(Fore.RED + "❌ Invalid Modrinth URL")
            input(Fore.YELLOW + "Press Enter to continue...")
            return
        
        if url_info['type'] == 'direct':
            print(Fore.GREEN + "✅ Direct download link detected!")
            
            download_url = url_info['url']
            filename = url_info['filename']
            plugin_name = filename.replace('.jar', '').replace('.zip', '')
            
            downloader = ModrinthDownloader()
            project_info = await downloader.fetch_project_info(url_info['project_id'])
            if project_info:
                plugin_name = project_info.get('title', plugin_name)
            
            print(Fore.GREEN + f"✅ Plugin: {plugin_name}")
            print(Fore.GREEN + f"✅ File: {filename}")
        
        elif url_info['type'] == 'page':
            project_slug = url_info['project_slug']
            
            print(Fore.CYAN + f"🔄 Fetching project '{project_slug}'...")
            
            downloader = ModrinthDownloader()
            project_info = await downloader.fetch_project_info(project_slug)
            
            if not project_info:
                print(Fore.RED + "❌ Project not found")
                input(Fore.YELLOW + "Press Enter to continue...")
                return
            
            plugin_name = project_info.get('title', project_slug)
            project_id = project_info.get('id', project_slug)
            
            print(Fore.GREEN + f"✅ Found: {plugin_name}")
            
            game_version = input(Fore.YELLOW + "Enter game version (e.g., '1.21.1'): " + Fore.WHITE).strip()
            loader = input(Fore.YELLOW + "Enter loader (paper/fabric/forge): " + Fore.WHITE).strip().lower()
            
            version_info = await downloader.fetch_version_info(project_id, game_version, loader)
            
            if not version_info:
                print(Fore.RED + "❌ No matching version found")
                input(Fore.YELLOW + "Press Enter to continue...")
                return
            
            if not version_info.get('files') or len(version_info['files']) == 0:
                print(Fore.RED + "❌ No files available")
                input(Fore.YELLOW + "Press Enter to continue...")
                return
            
            primary_file = version_info['files'][0]
            download_url = primary_file.get('url')
            filename = primary_file.get('filename', f"{plugin_name}.jar")
            
            print(Fore.GREEN + f"✅ File: {filename}")
    
    else:
        project_slug = user_input
        
        print(Fore.CYAN + f"🔄 Fetching project '{project_slug}'...")
        
        downloader = ModrinthDownloader()
        project_info = await downloader.fetch_project_info(project_slug)
        
        if not project_info:
            print(Fore.RED + "❌ Project not found")
            input(Fore.YELLOW + "Press Enter to continue...")
            return
        
        plugin_name = project_info.get('title', project_slug)
        project_id = project_info.get('id', project_slug)
        
        print(Fore.GREEN + f"✅ Found: {plugin_name}")
        
        game_version = input(Fore.YELLOW + "Enter game version (e.g., '1.21.1'): " + Fore.WHITE).strip()
        loader = input(Fore.YELLOW + "Enter loader (paper/fabric/forge): " + Fore.WHITE).strip().lower()
        
        version_info = await downloader.fetch_version_info(project_id, game_version, loader)
        
        if not version_info:
            print(Fore.RED + "❌ No matching version found")
            input(Fore.YELLOW + "Press Enter to continue...")
            return
        
        if not version_info.get('files') or len(version_info['files']) == 0:
            print(Fore.RED + "❌ No files available")
            input(Fore.YELLOW + "Press Enter to continue...")
            return
        
        primary_file = version_info['files'][0]
        download_url = primary_file.get('url')
        filename = primary_file.get('filename', f"{plugin_name}.jar")
        
        print(Fore.GREEN + f"✅ File: {filename}")
    
    if not download_url or not filename or not plugin_name:
        print(Fore.RED + "❌ Failed to get download information")
        input(Fore.YELLOW + "Press Enter to continue...")
        return
    
    available_proxies = len([p for p in PROXY_POOL if p not in FAILED_PROXIES])
    print(Fore.YELLOW + f"\n🚀 Starting download of {amount} copies...")
    print(Fore.CYAN + f"🌐 Using PROXY-ONLY mode")
    print(Fore.YELLOW + f"⚡ Available proxies: {available_proxies}/{len(PROXY_POOL)}\n")
    
    plugin_folder = get_plugin_folder(plugin_name)
    successful = 0
    failed = 0
    total_size = 0
    proxy_usage = {}
    
    for i in range(amount):
        unique_filename, save_path = generate_unique_filename(plugin_folder, filename, i)
        
        proxy = get_unique_proxy_for_project(plugin_name)
        
        if not proxy:
            failed += 1
            print(Fore.RED + f"❌ #{i+1}/{amount} - No proxy available")
            continue
        
        success, error, file_size, used_proxy = await download_file(download_url, save_path, proxy)
        
        proxy_key = used_proxy if used_proxy else "No Proxy"
        
        if success:
            successful += 1
            proxy_usage[proxy_key] = proxy_usage.get(proxy_key, 0) + 1
            total_size += file_size
            size_mb = file_size / (1024 * 1024)
            proxy_display = used_proxy.replace('http://', '') if used_proxy else "No Proxy"
            print(Fore.GREEN + f"🟢 #{i+1}/{amount} - {size_mb:.2f} MB - IP: {proxy_display[:50]}")
        else:
            failed += 1
            proxy_display = proxy.replace('http://', '') if proxy else "No Proxy"
            print(Fore.RED + f"❌ #{i+1}/{amount} - {error[:40]} - IP: {proxy_display[:40]}")
        
        await asyncio.sleep(random.uniform(1.0, 2.5))
    
    total_mb = total_size / (1024 * 1024)
    print(Fore.CYAN + "\n" + "="*60)
    print(Fore.GREEN + Style.BRIGHT + "DOWNLOAD COMPLETE".center(60))
    print(Fore.CYAN + "="*60)
    print(Fore.WHITE + f"Project: {Fore.YELLOW}{plugin_name}")
    print(Fore.WHITE + f"Success: {Fore.GREEN}{successful}{Fore.WHITE} | Failed: {Fore.RED}{failed}")
    print(Fore.WHITE + f"Total size: {Fore.YELLOW}{total_mb:.2f} MB")
    print(Fore.WHITE + f"Unique IPs used: {Fore.CYAN}{len(proxy_usage)}")
    if amount > 0:
        print(Fore.WHITE + f"Success rate: {Fore.GREEN}{(successful/amount*100):.1f}%")
    print(Fore.WHITE + f"Folder: {Fore.YELLOW}{plugin_folder}")
    
    if len(proxy_usage) > 0:
        print(Fore.CYAN + f"\n📊 IP Usage Distribution:")
        for i, (proxy_ip, count) in enumerate(list(proxy_usage.items())[:5], 1):
            clean_ip = proxy_ip.replace('http://', '').replace('https://', '')
            print(Fore.WHITE + f"   {i}. {clean_ip[:45]} - {count} downloads")
    
    logs = load_logs()
    logs.append({
        'timestamp': datetime.now().isoformat(),
        'plugin': plugin_name,
        'amount': amount,
        'successful': successful,
        'failed': failed,
        'size': total_size,
        'unique_ips': len(proxy_usage),
        'success_rate': (successful/amount*100) if amount > 0 else 0
    })
    save_logs(logs)
    
    input(Fore.YELLOW + "\nPress Enter to continue...")

def view_stats():
    """View download statistics"""
    logs = load_logs()
    
    if not logs:
        print(Fore.RED + "\n❌ No statistics available")
        input(Fore.YELLOW + "Press Enter to continue...")
        return
    
    print(Fore.CYAN + "\n" + "="*60)
    print(Fore.YELLOW + Style.BRIGHT + "DOWNLOAD STATISTICS".center(60))
    print(Fore.CYAN + "="*60)
    
    total_sessions = len(logs)
    total_downloads = sum(log.get('amount', 0) for log in logs)
    successful = sum(log.get('successful', 0) for log in logs)
    failed = sum(log.get('failed', 0) for log in logs)
    total_size = sum(log.get('size', 0) for log in logs)
    total_mb = total_size / (1024 * 1024)
    total_unique_ips = sum(log.get('unique_ips', 0) for log in logs)
    
    print(Fore.WHITE + f"Total sessions: {Fore.CYAN}{total_sessions}")
    print(Fore.WHITE + f"Total downloads: {Fore.CYAN}{total_downloads}")
    print(Fore.WHITE + f"Successful: {Fore.GREEN}{successful}")
    print(Fore.WHITE + f"Failed: {Fore.RED}{failed}")
    print(Fore.WHITE + f"Total size: {Fore.YELLOW}{total_mb:.2f} MB")
    print(Fore.WHITE + f"Unique IPs used: {Fore.CYAN}{total_unique_ips}")
    
    if total_downloads > 0:
        rate = (successful / total_downloads) * 100
        print(Fore.WHITE + f"Success rate: {Fore.CYAN}{rate:.1f}%")
    
    print(Fore.CYAN + "\n" + "="*60)
    print(Fore.YELLOW + "RECENT DOWNLOADS")
    print(Fore.CYAN + "="*60)
    
    for i, log in enumerate(reversed(logs[-5:]), 1):
        timestamp = log.get('timestamp', 'Unknown')[:19]
        plugin = log.get('plugin', 'Unknown')
        amount = log.get('amount', 0)
        success = log.get('successful', 0)
        print(Fore.WHITE + f"{i}. {Fore.YELLOW}{timestamp} {Fore.WHITE}- {Fore.CYAN}{plugin} {Fore.WHITE}({Fore.GREEN}{success}/{amount}{Fore.WHITE})")
    
    input(Fore.YELLOW + "\nPress Enter to continue...")

async def main_menu():
    """Main menu loop"""
    ensure_download_folder()
    print_banner()
    
    while True:
        available = len([p for p in PROXY_POOL if p not in FAILED_PROXIES]) if PROXY_POOL else 0
        
        print(Fore.CYAN + "\n" + "="*60)
        print(Fore.YELLOW + Style.BRIGHT + "MAIN MENU".center(60))
        print(Fore.CYAN + "="*60)
        print(Fore.WHITE + f"Proxies: {Fore.GREEN if available else Fore.RED}{available}{Fore.WHITE}/{Fore.CYAN}{len(PROXY_POOL)}" + 
              (f" {Fore.RED}({len(FAILED_PROXIES)} failed)" if FAILED_PROXIES else ""))
        print(Fore.CYAN + "\n1. " + Fore.WHITE + "Proxy Management")
        print(Fore.CYAN + "2. " + Fore.WHITE + "Download from Modrinth")
        print(Fore.CYAN + "3. " + Fore.WHITE + "View Statistics")
        print(Fore.CYAN + "0. " + Fore.WHITE + "Exit")
        
        choice = input(Fore.YELLOW + "\nChoice: " + Fore.WHITE).strip()
        
        if choice == '1':
            await proxy_menu()
        elif choice == '2':
            await download_menu()
        elif choice == '3':
            view_stats()
        elif choice == '0':
            print(Fore.CYAN + "\n👋 Goodbye!\n")
            break
        else:
            print(Fore.RED + "❌ Invalid choice")

# ============================================
# ENTRY POINT
# ============================================
if __name__ == "__main__":
    try:
        asyncio.run(main_menu())
    except KeyboardInterrupt:
        print(Fore.CYAN + "\n\n👋 Interrupted by user. Goodbye!\n")
    except Exception as e:
        print(Fore.RED + f"\n❌ Fatal error: {e}\n")
        import traceback
        traceback.print_exc()
