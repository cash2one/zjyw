# coding: utf8
# Django settings for zjyw project.
from django.conf import settings  
settings.configure()
# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SESSION_EXPIRE_AT_BROWSER_CLOSE = True # 会话关闭后自动删除session

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.7/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '+f_nx3^g0#4d3pl6ypr22hp2+*@!8bvghvcw$r+v%qn=4!c=^2'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

TEMPLATE_DEBUG = True

TIME_ZONE = "Etc/GMT-8"

LANGUAGE_CODE = 'zh-cn'

DEFAULT_CHARSET = 'utf-8'

ALLOWED_HOSTS = ['*']

FILE_CHARSET = 'utf-8'

import logging
LOGLEVEL = logging.DEBUG


# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'oa',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

#TEMPLATE_CONTEXT_PROCESSORS = (  
#    'django.core.context_processors.debug',  
#    'django.core.context_processors.i18n',  
#    'django.core.context_processors.media',  
#    'django.core.context_processors.static',  
#    'django.contrib.auth.context_processors.auth',  
#    'django.contrib.messages.context_processors.messages',  
#)  

ROOT_URLCONF = 'oa.urls'

WSGI_APPLICATION = 'zjyw.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.7/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'zjyw',
        'USER': 'zjyw',
        'PASSWORD': 'zjyw',
        'HOST': '10.2.46.150',  
        'PORT': '3306',   
        
    }
}

DB_TYPE = 'mysql'
DB_CONSTR = dict( host='localhost',user='zjyw',passwd='zjyw',db='zjyw',port=3306)


# 日志目录定义
LOGDIR = os.path.join( BASE_DIR , 'log' )
CACHE_DIR = os.path.join( BASE_DIR , 'log')
FILES_DIR = os.path.join( BASE_DIR , 'modules')

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.7/howto/static-files/

STATIC_URL = '/static/'

STATIC_ROOT = os.path.join( BASE_DIR, 'static' )  # admin用户管理页面用到， python manage.py collectstatic 用到这个地址

#STATICFILES_DIRS = (
#    os.path.join( BASE_DIR, 'static' ),
#)
#
STATIC_DIR =os.path.join( BASE_DIR, 'static' )  # url
TEMPLATE_DIR = os.path.join( BASE_DIR, 'templates' )

TEMPLATE_DIRS = (  
    os.path.join( BASE_DIR, 'templates' ),  
    # Don't forget to use absolute paths, not relative paths.  
)  