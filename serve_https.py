import http.server
import ssl
import os
import socket
import subprocess

def generate_self_signed_cert(cert_file="server.pem"):
    if not os.path.exists(cert_file):
        print("Generating self-signed SSL certificate...")
        try:
            cmd = [
                "openssl", "req", "-new", "-x509", "-days", "365",
                "-nodes", "-out", cert_file, "-keyout", cert_file,
                "-subj", "/CN=192.168.10.212"
            ]
            subprocess.run(cmd, check=True)
            print("Certificate generated.")
        except Exception as e:
            print(f"Openssl not available: {e}")

class CustomHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory="build/web", **kwargs)

    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

def run_server(port=3000):
    generate_self_signed_cert()
    server_address = ('0.0.0.0', port)
    httpd = http.server.HTTPServer(server_address, CustomHandler)
    
    if os.path.exists("server.pem"):
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.load_cert_chain("server.pem")
        httpd.socket = context.wrap_socket(httpd.socket, server_side=True)
        print(f"Serving HTTPS on https://0.0.0.0:{port} (https://192.168.10.212:{port})")
    else:
        print(f"Serving HTTP on http://0.0.0.0:{port} (http://192.168.10.212:{port})")
        
    httpd.serve_forever()

if __name__ == '__main__':
    run_server()
