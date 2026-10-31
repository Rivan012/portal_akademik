import json
import re
import urllib.request
import urllib.parse
import urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler
import http.cookiejar
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

class DevProxyHandler(BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With')

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_POST(self):
        if self.path == '/login':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            try:
                data = json.loads(post_data.decode('utf-8'))
                username = data.get('username', '')
                password = data.get('password', '')

                cj = http.cookiejar.CookieJar()
                opener = urllib.request.build_opener(
                    urllib.request.HTTPCookieProcessor(cj),
                    urllib.request.HTTPSHandler(context=ctx)
                )

                # 1. GET login page
                req1 = urllib.request.Request(
                    'https://portal.unib.ac.id/login/login',
                    headers={'User-Agent': 'Mozilla/5.0'}
                )
                with opener.open(req1, timeout=15) as res1:
                    html1 = res1.read().decode('utf-8')

                csrf_match = re.search(r'name=["\']_token["\'] value=["\']([^"\']+)["\']', html1)
                if not csrf_match:
                    raise Exception('CSRF token tidak ditemukan')
                csrf = csrf_match.group(1)

                # 2. POST login
                payload = urllib.parse.urlencode({
                    '_token': csrf,
                    'username': username,
                    'password': password
                }).encode('utf-8')
                req2 = urllib.request.Request(
                    'https://portal.unib.ac.id/login/login',
                    data=payload,
                    headers={
                        'User-Agent': 'Mozilla/5.0',
                        'Referer': 'https://portal.unib.ac.id/login/login',
                        'Content-Type': 'application/x-www-form-urlencoded'
                    }
                )
                with opener.open(req2, timeout=15) as res2:
                    final_url = res2.geturl()
                    html2 = res2.read().decode('utf-8')

                if 'login' in final_url:
                    raise Exception('Username atau password salah')

                # 3. Extract access token
                patterns = [
                    r'''Alpine\.store\(\s*['"]access_token['"]\s*,\s*['"]([^'"]+)['"]\s*\)''',
                    r'''['"]access_token['"]\s*:\s*['"]([^'"]+)['"]''',
                ]
                access_token = None
                for p in patterns:
                    m = re.search(p, html2)
                    if m:
                        access_token = m.group(1)
                        break

                if not access_token:
                    raise Exception('Access token tidak ditemukan')

                # 4. Extract KRS & Nilai IDs
                id_krs = None
                id_nilai = None
                try:
                    req_krs = urllib.request.Request('https://portal.unib.ac.id/krs/registration', headers={'User-Agent': 'Mozilla/5.0'})
                    with opener.open(req_krs, timeout=10) as rk:
                        krs_html = rk.read().decode('utf-8')
                        m_k = re.search(r'idKRS:\s*[\'\"]([^\'\"]+)[\'\"]', krs_html)
                        if m_k:
                            id_krs = m_k.group(1)
                except Exception:
                    pass

                try:
                    req_g = urllib.request.Request('https://portal.unib.ac.id/grade/student', headers={'User-Agent': 'Mozilla/5.0'})
                    with opener.open(req_g, timeout=10) as rg:
                        g_html = rg.read().decode('utf-8')
                        m_g = re.search(r'grade-list-student/([a-zA-Z0-9%_\-\+=]+)', g_html)
                        if m_g:
                            id_nilai = m_g.group(1)
                except Exception:
                    pass

                resp = {
                    'success': True,
                    'csrf_token': csrf,
                    'xsrf_token': next((urllib.parse.unquote(c.value) for c in cj if c.name == 'XSRF-TOKEN'), None),
                    'portal_session': next((urllib.parse.unquote(c.value) for c in cj if c.name == 'portal_session'), None),
                    'access_token': access_token,
                    'username': username,
                    'id_krs': id_krs,
                    'id_nilai': id_nilai
                }
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(resp).encode('utf-8'))
            except Exception as e:
                self.send_response(400)
                self.send_header('Content-Type', 'application/json')
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({'success': False, 'message': str(e)}).encode('utf-8'))
        elif self.path.startswith('/api/'):
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length) if content_length > 0 else b''
            target_path = self.path[len('/api/'):]
            target_url = f'https://api-gateway.unib.ac.id/backend/api/{target_path}'
            headers = {'User-Agent': 'Mozilla/5.0'}
            if 'Authorization' in self.headers:
                headers['Authorization'] = self.headers['Authorization']
            if 'Content-Type' in self.headers:
                headers['Content-Type'] = self.headers['Content-Type']
            if 'Accept' in self.headers:
                headers['Accept'] = self.headers['Accept']

            try:
                req = urllib.request.Request(target_url, data=post_data, headers=headers, method='POST')
                with urllib.request.urlopen(req, context=ctx, timeout=35) as res:
                    body = res.read()
                    self.send_response(res.status)
                    self.send_header('Content-Type', res.headers.get('Content-Type', 'application/json'))
                    self._send_cors_headers()
                    self.end_headers()
                    self.wfile.write(body)
            except urllib.error.HTTPError as he:
                body = he.read()
                self.send_response(he.code)
                self.send_header('Content-Type', 'application/json')
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(body)
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e)}).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        if self.path.startswith('/api/'):
            # Proxy to api-gateway.unib.ac.id/backend/api/...
            target_path = self.path[len('/api/'):]
            target_url = f'https://api-gateway.unib.ac.id/backend/api/{target_path}'
            headers = {'User-Agent': 'Mozilla/5.0'}
            if 'Authorization' in self.headers:
                headers['Authorization'] = self.headers['Authorization']
            if 'Accept' in self.headers:
                headers['Accept'] = self.headers['Accept']

            try:
                req = urllib.request.Request(target_url, headers=headers)
                with urllib.request.urlopen(req, context=ctx, timeout=35) as res:
                    body = res.read()
                    self.send_response(res.status)
                    self.send_header('Content-Type', res.headers.get('Content-Type', 'application/json'))
                    self._send_cors_headers()
                    self.end_headers()
                    self.wfile.write(body)
            except urllib.error.HTTPError as he:
                body = he.read()
                self.send_response(he.code)
                self.send_header('Content-Type', 'application/json')
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(body)
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self._send_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({'error': str(e)}).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

if __name__ == '__main__':
    port = 8080
    server = HTTPServer(('127.0.0.1', port), DevProxyHandler)
    print(f'Dev Proxy running on http://127.0.0.1:{port}')
    server.serve_forever()
