# coding: utf8
# 功能描述 ：  登录及首页信息展示
# 作　　者 ：  成德功
# 日　　期 ：  2016/5/30
# 版　　本 ：  V1.00
# 更新履历 ：  V1.00 2016/5/17 成德功 创建.
from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.http import HttpResponseRedirect  # 例如：return HttpResponseRedirect('/index/')  #跳转到index界面
from django.core.urlresolvers import reverse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required   ##@login_required(login_url="/login/")  如果用户未登录，重定向到settings.LOGIN_URL(即login_url),如果用户已登录则正常执行。
from django.contrib.auth import login, logout, authenticate
import os, json
from zjyw_utils import *

log.init_log( 'login' , True )

"""
数据库操作的使用方法：
ls = []
sql = "select * from XXX "
with myapi.connection() as con:
    cur = con.cursor()
    rs = myapi.sql_execute(cur, sql)
    while rs.next():
        rs_lst = rs.to_dict()
        ls.append(rs_lst)
    log.info( "login", '已进入函数。。。。%s', repr(ls) )
"""

def index(request):
    return render_to_response( 'login.html', {}, context_instance=RequestContext(request) )
   
def login_view(request):
    try:
        content={}
        content['xym'] = '0'
        log.info( "login", '已进入函数。。。。' )
        username = request.POST.get('username','').encode('utf8')
        password = request.POST.get('password','').encode('utf8')
        log.info( "login", '用户【%s】登录', username)
        user = authenticate(username=username, password=password)
        if user is not None:
            log.info( "login", '把用户名与密码存放到session中，用于之后的判断用户是否登陆')
            login(request, user)
            request.session[ 'username' ] = username
            request.session[ 'password' ] = password
#            #================================shanchu ==========================
#            sql = "select * from AgentTask a where a.task_agent in(select b.group_agent from AgentTask a,AgentGroupInfo b where b.group_id=a.task_group group by b.group_id)"
#            sql1 = "select b.group_agent from AgentTask a,AgentGroupInfo b where b.group_id=a.task_group group by b.group_id"
#            #sql2 = "select * from AgentTask a where a.task_agent in()"%;
#            with myapi.connection() as con:
#                cur = con.cursor()
#                cur.execute(sql1)
#                rs1 = cur.fetchall()
#                log.info( "login", '===========rs1==================%s',rs1 )
#                ls=()
#                for l in rs1:
#                    log.info( "login", '===========len==================%s',repr(len(l[0])) )
#                    sql2 = "select task_id, a.task_type, a.task_module, a.task_circle, a.task_start_time from AgentTask a where a.task_agent in %s and a.task_group is not null and a.task_state='2'" % ( '11111', (repr(tuple(l[0].split(','))) if len(l[0])!=8 else "(%s)"%l[0]) )
#                    log.info( "login", '===========sql2==================%s', sql2)
#                    cur.execute(sql2)
#                    rs2 = cur.fetchall()
#                    log.info( "login", '================rs2=============%s',repr(rs2) )
#                log.info( "login", '===========ls==================%s', ls)
#                cur.execute(sql)
#                rs = cur.fetchall()
#                log.info( "login", '================rs=============%s',repr(rs) )
#            #================================shanchu ==========================
            log.info( "login", '会话session：【%s】', repr(request) )
            log.info( "login", '用户【%s】登录验证成功', username)
            # 转到成功页面
            content['xym'] = '000000'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "login", '用户名或密码码输入错误')
            
            content['xyxx'] = '用户名或密码码输入错误！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[login_view]执行错误:%s' % str( e )
        log.exception( 'login', '后台函数[login_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

def main_view(request):
    # 通过会话判断用户是否登陆， 例：request.session.get('username') --需要转码后使用
    try:
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        username = request.session.get('username').encode('utf8')
        log.info( "login", '来自session的用户名：%s', username )
        ls = []
        sql = "select * from AgentInfo "
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_lst = rs.to_dict()
                ls.append(rs_lst)
        return render_to_response( 'index.html', {'zjxx_dic':ls}, context_instance=RequestContext(request) )
    except Exception, e :
        log.exception( 'login', '后台函数[login_view]执行错误:%s', str( e ) )
        return render_to_response( 'index.html', {'xyxx':'后台函数[main_view]执行错误:%s' % str( e )}, context_instance=RequestContext(request) )