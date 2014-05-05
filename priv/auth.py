import time
import json
from oauth2client import crypt

def get_signed_jwt(client_id, scope, duration_seconds, key_filename):
    with open(key_filename, 'rb') as f:
        key_data = f.read()

    signer = crypt.OpenSSLSigner.from_string(key_data)

    now = long(time.time())
    jwt_payload = {'aud': 'https://accounts.google.com/o/oauth2/token',
                   'iss': client_id,
                   'scope': scope,
                   'iat': now,
                   'exp': now + duration_seconds}

    jwt = crypt.make_signed_jwt(signer, jwt_payload)
    return jwt
