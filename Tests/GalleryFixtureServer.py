#!/usr/bin/env python3
"""Isolated UI-test endpoint. Never bundled or used by production configuration."""
import argparse
import json
import ssl
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--certificate", required=True)
    parser.add_argument("--key", required=True)
    parser.add_argument("--requests", required=True)
    parser.add_argument("--port", type=int, default=0)
    args = parser.parse_args()

    class Handler(BaseHTTPRequestHandler):
        def do_POST(self):
            if self.path != "/v1/completions":
                self.send_error(404)
                return
            authorization = self.headers.get("Authorization", "")
            if not authorization.startswith("Bearer ") or not authorization[7:].strip():
                self.send_error(401)
                return
            request = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
            last = request["messages"][-1]
            text = last["text"]
            if last["role"] != "user" or not text.startswith("Gallery exchange "):
                self.send_error(422)
                return
            with Path(args.requests).open("a") as log:
                log.write(json.dumps({
                    "characterID": request["character"]["id"],
                    "authenticated": True,
                    "testTokenMatches": authorization == "Bearer GalleryUITestToken123",
                    "tokenLength": len(authorization[7:]),
                    "message": text,
                    "conversationID": last["conversationID"],
                }) + "\n")
            data = json.dumps({"text": "Gallery fixture reply " + text.rsplit(" ", 1)[1]}).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(args.certificate, args.key)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    print(f"GALLERY_FIXTURE_URL=https://localhost:{server.server_port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
