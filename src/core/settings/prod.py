"""Production settings and globals."""
from .base import *

ALLOWED_HOSTS = get_secret("prod_allowed_hosts")

STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
