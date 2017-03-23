from django.conf import settings  
settings.configure() 

# Build paths inside the project like this: os.path.join(BASE_DIR, ...
import os
ROOT = os.path.dirname(os.path.abspath(__file__))



print('======',ROOT)




#def application( env, start_response ):
#    start_response( '200 OK', [('Content-Type', 'text/html')])
#    return "Hello world"