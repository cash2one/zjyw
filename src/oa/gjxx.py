# coding: utf8
# 功能描述 ：  任务信息展示及任务定制
# 作　　者 ：  成德功
# 日　　期 ：  2016/7/4
# 版　　本 ：  V1.00
# 更新履历 ：  V1.00 2016/6/27 成德功 创建.
from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.template.loader import render_to_string
import os, json
from zjyw_utils import *

log.init_log( 'gjxx' , True )

def gjxx_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        
        # 获取任务信息
        sql = "select * from AgentWarn where warn_isclose='1' order  by warn_id desc "
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_lst = rs.to_dict()
                ls.append(rs_lst)
        # log.info( "gjxx",  repr(ls))
        content['xym'] = '000000'
        content['cont'] = render_to_string( 'gjxx.html', {'gjxx_dic':ls} )
        return HttpResponse( json.dumps( content), content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[gjxx_view]执行错误:%s' % str( e )
        log.exception( 'gjxx', '后台函数[gjxx_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

def pb_gjxx_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        warn_type = request.POST.get('warn_type','').encode('utf8')
        # 获取任务信息
        sql = "update AgentWarn set warn_isclose='0' where warn_type='%s'" % warn_type
        log.info( "gjxx", "告警信息屏蔽SQL:【%s】" % sql )
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
        content['xym'] = '000000'
        content['xyxx'] = '屏蔽告警信息成功'
        return HttpResponse( json.dumps( content), content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[gjxx_view]执行错误:%s' % str( e )
        log.exception( 'gjxx', '后台函数[gjxx_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
       
def gjxx_pb_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        
        # 获取任务信息
        sql = "select * from AgentWarn where warn_isclose='0' group by warn_type order  by warn_id desc  "
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_lst = rs.to_dict()
                ls.append(rs_lst)
        log.info( "gjxx",  repr(ls))
        content['xym'] = '000000'
        content['cont'] = render_to_string( 'gjcl.html', {'gjxx_dic':ls} )
        return HttpResponse( json.dumps( content), content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[gjxx_pb_view]执行错误:%s' % str( e )
        log.exception( 'gjxx', '后台函数[gjxx_pb_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

def no_pb_gjxx_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        warn_type = request.POST.get('warn_type','').encode('utf8')
        # 获取任务信息
        sql = "update AgentWarn set warn_isclose='1' where warn_type='%s'" % warn_type
        log.info( "gjxx", "告警信息取消屏蔽SQL:【%s】" % sql )
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
        content['xym'] = '000000'
        content['xyxx'] = '取消告警屏蔽成功'
        return HttpResponse( json.dumps( content), content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[no_pb_gjxx_view]执行错误:%s' % str( e )
        log.exception( 'gjxx', '后台函数[no_pb_gjxx_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
