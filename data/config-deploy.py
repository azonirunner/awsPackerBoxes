# copied version of netflix config for security monkey
#
# Insert any config items here.
# This will be fed into Flask/SQLAlchemy inside security_monkey/__init__.py

LOG_LEVEL = "DEBUG"
LOG_FILE = "security_monkey-deploy.log"

SQLALCHEMY_DATABASE_URI = 'postgresql://postgres:securitymonkeypassword@localhost:5432/secmonkey'

SQLALCHEMY_POOL_SIZE = 50
SQLALCHEMY_MAX_OVERFLOW = 15
ENVIRONMENT = 'ec2'
USE_ROUTE53 = False
FQDN = 'ec2-XX-XXX-XXX-XXX.compute-1.amazonaws.com'
API_PORT = '5000'
WEB_PORT = '443'
FRONTED_BY_NGINX = True
NGINX_PORT = '443'
WEB_PATH = '/static/ui.html'
BASE_URL = 'https://{}/'.format(FQDN)

SECRET_KEY = '<SOME_RANDOM_STRING_HERE>'

MAIL_DEFAULT_SENDER =  'securitymonkey@example.com'
SECURITY_REGISTERABLE = True
SECURITY_CONFIRMABLE = False
SECURITY_RECOVERABLE = False
SECURITY_PASSWORD_HASH = 'bcrypt'
SECURITY_PASSWORD_SALT = '<ANOTHER_RANDOM_STRING_HERE>'

SECURITY_POST_LOGIN_VIEW = BASE_URL
SECURITY_POST_REGISTER_VIEW = BASE_URL
SECURITY_POST_CONFIRM_VIEW = BASE_URL
SECURITY_POST_RESET_VIEW = BASE_URL
SECURITY_POST_CHANGE_VIEW = BASE_URL

# This address gets all change notifications
SECURITY_TEAM_EMAIL = ['securityteam@example.com']

# These are only required if using SMTP instead of SES
EMAILS_USE_SMTP = False     # Otherwise, Use SES
MAIL_SERVER = 'smtp.example.com'
MAIL_PORT = 465
MAIL_USE_SSL = True
MAIL_USERNAME = 'username'
MAIL_PASSWORD = 'password'
