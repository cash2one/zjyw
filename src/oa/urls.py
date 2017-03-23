# coding: utf8

from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.conf import settings
import os
admin.autodiscover()

urlpatterns = patterns('',
    # 静态文件
    url(r'^css/(.*)$' , 'django.views.static.serve', {'document_root': os.path.join( settings.STATIC_DIR , 'css' ) } ) ,
    url(r'^font/(.*)$' , 'django.views.static.serve', {'document_root': os.path.join( settings.STATIC_DIR , 'font' ) } ) ,
    url(r'^img/(.*)$' , 'django.views.static.serve', {'document_root': os.path.join( settings.STATIC_DIR , 'img' ) } ) ,
    url(r'^js/(.*)$' , 'django.views.static.serve', {'document_root': os.path.join( settings.STATIC_DIR , 'js' ) } ) ,
    url(r'^modules/(.*)$' , 'django.views.static.serve', {'document_root': os.path.join( settings.FILES_DIR ) } ),
    
    # 登录页面
    url(r'^$' , 'oa.views.index', name='index') ,
    
    #登陆部分
    url(r'^login_up/$', 'oa.views.login_view'), 
    url(r'^main/$', 'oa.views.main_view'), 
    url(r'^admin/', include(admin.site.urls)),
    
    #主机管理部分
    url(r'^zjxx/$', 'oa.zjxx.zjxx_view'), 
    url(r'^zjxx_detail/$', 'oa.zjxx.zjxx_detail_view'), 
    url(r'^zjxx_del/$', 'oa.zjxx.zjxx_del_view'), 
    url(r'^zjfz/$', 'oa.zjxx.zjfz_view'),
    url(r'^save_fz/$', 'oa.zjxx.save_zjfz_view'),
    url(r'^zjid/$', 'oa.zjxx.zjid_view'),
    url(r'^zjid_made/$', 'oa.zjxx.zjid_made_view'), 
    url(r'^zjxx_checkinfo/$', 'oa.zjxx.zjxx_checkinfo_view'),
    url(r'^zjxx_check_detail_info/$', 'oa.zjxx.zjxx_check_detail_info_view'),
    
    # 任务管理部分
    url(r'^rwxx/$', 'oa.rwxx.rwxx_view'),
    url(r'^rwdz/$', 'oa.rwxx.rwdz_view'),
    url(r'^save_rwdz/$', 'oa.rwxx.save_rwdz_view'),
    url(r'^task_start/$', 'oa.rwxx.task_start_view'),
    url(r'^task_stop/$', 'oa.rwxx.task_stop_view'),
    url(r'^task_del/$', 'oa.rwxx.task_del_view'),
    url(r'^task_add_tz/$', 'oa.rwxx.task_add_tz_view'),
    url(r'^task_edit_tz/$', 'oa.rwxx.task_edit_tz_view'),
    url(r'^task_add/$', 'oa.rwxx.task_add_view'),
    url(r'^task_edit/$', 'oa.rwxx.task_edit_view'),
    
    # 告警管理部分
    url(r'^gjxx/$', 'oa.gjxx.gjxx_view'),
    url(r'^pb_gjxx/$', 'oa.gjxx.pb_gjxx_view'),
    url(r'^gjxx_pb/$', 'oa.gjxx.gjxx_pb_view'),
    url(r'^no_pb_gjxx/$', 'oa.gjxx.no_pb_gjxx_view'),
    
    #=====================服务端部分===================
    # 任务查询
    url(r'^task/$', 'oa.zjserver.task_view'),
    # 告警信息上送
    url(r'^alarm/$', 'oa.zjserver.alarm_view'),
    # 体检信息上送
    url(r'^check/$', 'oa.zjserver.check_view'),
    # 体检信息上送
    url(r'^host_info/$', 'oa.zjserver.host_view'), 

)