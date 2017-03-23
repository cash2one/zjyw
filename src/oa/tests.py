from django.conf import settings  
settings.configure() 

# Build paths inside the project like this: os.path.join(BASE_DIR, ...
import os
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ss = os.path.join( BASE_DIR, 'templates' )
print('======',ss)

