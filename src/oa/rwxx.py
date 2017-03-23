# coding: utf8
# 功能描述 ：  任务信息展示及任务定制
# 作　　者 ：  成德功
# 日　　期 ：  2016/6/24
# 版　　本 ：  V1.00
# 更新履历 ：  V1.00 2016/6/16 成德功 创建.
from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.template.loader import render_to_string
import os, json, datetime
from zjyw_utils import *

log.init_log( 'rwxx' , True )

def rwxx_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        
        # 获取任务信息
        sql = "select task_id, b.module_name as task_module, task_detail, task_circle, task_state from AgentTask a, TaskModuleInfo b where a.task_module=b.module_id"
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_lst = rs.to_dict()
                ls.append(rs_lst)
        if ls:
            log.info( "rwxx",  repr(ls))
            content['xym'] = '000000'
            content['cont'] = render_to_string( 'rwxx.html', {'rwxx_dic':ls} )
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "rwxx", '主机信息不存在')
            
            content['xyxx'] = '主机信息不存在！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[rwxx_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[rwxx_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

def rwdz_view(request):
    try:
        content={}
        ls_group = []
        ls_module = []
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        
        # 查询所有主机组信息
        group_sql = "select * from AgentGroupInfo "
        # 查询所有模板信息
        module_sql = "select * from TaskModuleInfo "
        with myapi.connection() as con:
            cur = con.cursor()
            group_rs = myapi.sql_execute(cur, group_sql)
            while group_rs.next():
                rs_group = group_rs.to_dict()
                ls_group.append(rs_group)
            
            module_rs = myapi.sql_execute(cur, module_sql)
            while module_rs.next():
                rs_module = module_rs.to_dict()
                ls_module.append(rs_module)
        if ls_group or ls_module:
            log.info( "rwxx", "获取到的主机组信息：【%s】", repr(ls_group) or '' )
            log.info( "rwxx", "获取到的任务模板：【%s】", repr(ls_module) or '' )
            content['xym'] = '000000'
            content['cont'] = render_to_string( 'rwdz.html', {'ls_group':ls_group, 'ls_module':ls_module} )
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "rwxx", '主机信息不存在')
            content['xyxx'] = '主机信息不存在！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[rwxx_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[rwxx_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

def save_rwdz_view(request):
    try:
        content = {}
        ls = []
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        zjz = request.POST.get('zjz','').encode('utf8')
        mb = request.POST.get('mb','').encode('utf8')
        module_sql = "select * from AgentGroupInfo where group_task_module='%s'and group_id='%s' "% ( mb, zjz  )
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, module_sql)
            while rs.next():
                rs_dic = rs.to_dict()
                ls.append(rs_dic)
        if ls:
            # 返回错误信息
            content['xym'] = '000000'
            log.info( "rwxx", '主机组任务模板未变更！')
            content['xyxx'] = '主机组任务模板未变更！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        # 更新主机组下的模板信息
        sql = "update AgentGroupInfo set group_task_module='%s' where group_id='%s'" % ( mb, zjz  )
        log.info( "rwxx", "主机组任务定制后台更新SQL:【%s】" % sql )
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
        log.info( "rwxx", "主机组任务模板定制成功！===============%s"%repr(cur.rowcount) )
        if cur.rowcount == 1:
            log.info( "rwxx", "主机组任务模板定制成功！===%s" )
            content['xym'] = '000000'
            content['xyxx'] = '定制成功！'
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "rwxx", '主机组任务模板定制失败！')
            content['xyxx'] = '主机组任务模板定制失败！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[save_rwdz_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[save_rwdz_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

# 启动任务
def task_start_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        id = request.POST.get('id','').encode('utf8')
        # 启动任务：状态修改为 1 任务状态 0：未执行，1：等待运行，2：停止运行,9：已执行
        sql = "update  AgentTask set task_state='1' where task_id='%s' " % id  
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
           
        log.info( "rwxx", "任务启动状态更新sql【%s】", sql )
        if cur.rowcount == 1:
            log.info( "rwxx", "任务启动成功！" )
            content['xym'] = '000000'
            content['xyxx'] = '任务启动成功！'
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "rwxx", '任务启动失败')
            
            content['xyxx'] = '任务启动失败！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[task_start_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[task_start_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
        
# 停止任务
def task_stop_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        id = request.POST.get('id','').encode('utf8')
        # 停止任务：状态修改为 0   任务状态 0：未执行，1：等待运行，2：停止运行,9：已执行
        sql = "update  AgentTask set task_state='2' where task_id='%s' " % id 
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
           
        log.info( "rwxx", "任务停止状态更新sql【%s】", sql )
        if cur.rowcount == 1:
            log.info( "rwxx", "任务停止成功！" )
            content['xym'] = '000000'
            content['xyxx'] = '任务停止成功！'
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "rwxx", '任务停止失败')
            
            content['xyxx'] = '任务停止失败！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[task_stop_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[task_stop_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

# 删除任务
def task_del_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        id = request.POST.get('id','').encode('utf8')
        # 停止任务：状态修改为 0
        sql = "delete from AgentTask where task_id='%s' " % id 
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
           
        log.info( "rwxx", "任务删除sql【%s】", sql )
        if cur.rowcount == 1:
            log.info( "rwxx", "任务删除成功！" )
            content['xym'] = '000000'
            content['xyxx'] = '任务删除成功！'
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "rwxx", '任务删除失败')
            
            content['xyxx'] = '任务删除失败！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[task_del_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[task_del_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

# 添加任务页面跳转
def task_add_tz_view(request):
    try:
        ls_module = []
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        
        # 查询所有模板信息
        module_sql = "select * from TaskModuleInfo "
        with myapi.connection() as con:
            cur = con.cursor()
            module_rs = myapi.sql_execute(cur, module_sql)
            while module_rs.next():
                rs_module = module_rs.to_dict()
                ls_module.append(rs_module)
        return render_to_response( 'zjxx_detail_rwxx_add.html', {'ls_module':ls_module}, context_instance=RequestContext(request) )
    except Exception, e :
        log.exception( 'rwxx', '后台函数[task_add_tz_view]执行错误:%s', str( e ) )
        return render_to_response( 'zjxx_detail_rwxx_add.html', {'xyxx':'后台函数[task_add_tz_view]执行错误:%s' % str( e )}, context_instance=RequestContext(request) )

# 新增任务
def task_add_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        # {"rwmc":rwmc,"rwms":rwms,"circle":circle,"start_time":start_time,"state":state,"select_module":select_module}
        rwmc = request.POST.get('rwmc','').encode('utf8')
        rwms = request.POST.get('rwms','').encode('utf8')
        circle = request.POST.get('circle','').encode('utf8')
        start_time = request.POST.get('start_time','').encode('utf8') # 需要修改成"%Y-%m-%d %H:%M:%S"这种格式，因为展示任务信息时更人性化TODO
        state = request.POST.get('state','').encode('utf8')
        select_module = request.POST.get('select_module','').encode('utf8')
        zjid = request.session.get('agent_id','').encode('utf8')
        username = request.session.get('username','').encode('utf8')
        # 查询新增任务是否已存在
        sql = "select * from AgentTask where task_group is null and task_module='%s' and task_agent='%s' " % ( select_module, zjid )
        log.info( "rwxx", "查询新增任务是否已存在sql【%s】", sql )
        with myapi.connection() as con:
            cur = con.cursor()
#            rs = myapi.sql_execute(cur, sql)
#            while rs.next():
#                rs_dic = rs.to_dict()
#                ls.append(rs_dic)
#            log.info( "rwxx", '===============================【%s】'%repr(ls))
#            if ls:
#                # 返回错误信息
#                log.info( "rwxx", '添加失败，任务已存在')
#                content['xym'] = '111111'
#                content['xyxx'] = '添加失败，任务已存在！'
#                return HttpResponse( json.dumps( content) , content_type='application/json' )
            # 获取递增的任务ID
            sql_id = "select nextval('task_id')"
            cur.execute(sql_id)
            rs = cur.fetchall()
            # 任务ID组成规则
            task_id = datetime.datetime.now().strftime("%Y%m%d") + str(int(rs[0][0]))
            # 新增任务信息 任务类型: 1主机体检 ; 2webshell检测  task_state:1：等待运行，2：停止运行
            sql = "insert into  AgentTask(task_id, task_name, task_detail, task_circle, task_start_time, task_state, task_agent, task_user_join, task_time_join, task_module, task_type )values( '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s','1')" % ( task_id, rwmc, rwms, circle, start_time, state, zjid, username, datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), select_module )
            log.info( "rwxx", "任务新增sql【%s】", sql )
            # 需要根据模板ID更新任务名称，目前一个模板对应的任务名称、模板名称都是固定的，用于体检报告的展示描述TODO
            cur.execute(sql)
            if cur.rowcount == 1:
                # 更新  "主机信息表"  中的该主机的agent_task任务字段，追加任务ID
                sql_zjxx = "update AgentInfo set agent_task=CONCAT( agent_task, '%s' ) where agent_id='%s' "%( task_id, zjid )
                cur.execute( sql_zjxx )
                log.info( "rwxx", "任务新增成功！" )
                content['xym'] = '000000'
                content['xyxx'] = '任务新增成功！'
                return HttpResponse( json.dumps( content), content_type='application/json' )
            else:
                # 返回错误信息
                log.info( "rwxx", '任务新增失败')
                content['xyxx'] = '任务新增失败！'
                return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[task_add_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[task_add_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

# 添加任务页面跳转
def task_edit_tz_view(request):
    try:
        id = request.GET.get('id','').encode('utf8')
        rwmc = request.GET.get('rwmc','').encode('utf8')
        rwms = request.GET.get('rwms','').encode('utf8')
        circle = request.GET.get('circle','').encode('utf8')
        start_time = request.GET.get('start_time','').encode('utf8')
        state = request.GET.get('state','').encode('utf8')
        select_module = request.GET.get('select_module','').encode('utf8')
        ls_module = []
        date_week = ''
        date_time1 = ''
        date_time2 = ''
        log.info( "rwxx", "=================circle==============%s", circle )
        log.info( "rwxx", "=================start_time==============%s", start_time )
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        if circle=='1':
            date_time1 = start_time[:5]
        if circle=='2':
            log.info( "rwxx", "===============================【%s】", start_time )
            t_time = start_time.split('-')
            date_time1 = t_time[1][:5]
            date_week = t_time[0]
        if circle=='3': # 只有周期为每月的情况下task_start_time是标准日期 yyyy-mm-dd hh:mm:ss
            date_time2 = start_time
        # 查询所有模板信息
        module_sql = "select * from TaskModuleInfo "
        with myapi.connection() as con:
            cur = con.cursor()
            module_rs = myapi.sql_execute(cur, module_sql)
            while module_rs.next():
                rs_module = module_rs.to_dict()
                ls_module.append(rs_module)
        return render_to_response( 'zjxx_detail_rwxx_edit.html', {"id":id,"rwmc":rwmc,"rwms":rwms,"circle":circle,"date_time1":date_time1 if date_time1 else '', "date_week":date_week if date_week else '', "date_time2":date_time2 if date_time2 else '',  "state":state,"select_module":select_module,"ls_module":ls_module}, context_instance=RequestContext(request) )
    except Exception, e :
        log.exception( 'rwxx', '后台函数[zjxx_detail_rwxx_edit]执行错误:%s', str( e ) )
        return render_to_response( 'zjxx_detail_rwxx_edit.html', {'xyxx':'后台函数[task_edit_tz_view]执行错误:%s' % str( e )}, context_instance=RequestContext(request) )
        
# 编辑任务
def task_edit_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        # {"rwmc":rwmc,"rwms":rwms,"circle":circle,"start_time":start_time,"state":state,"select_module":select_module}
        id = request.POST.get('id','').encode('utf8')
        rwmc = request.POST.get('rwmc','').encode('utf8')
        rwms = request.POST.get('rwms','').encode('utf8')
        circle = request.POST.get('circle','').encode('utf8')
        start_time = request.POST.get('start_time','').encode('utf8')
        state = request.POST.get('state','').encode('utf8')
        select_module = request.POST.get('select_module','').encode('utf8')
        zjid = request.session.get('agent_id','').encode('utf8')
        username = request.session.get('username','').encode('utf8')
        # 新增任务信息
        sql = "update AgentTask set task_name='%s', task_detail='%s', task_circle='%s', task_start_time='%s', task_state='%s', task_user_join='%s', task_time_join='%s', task_module='%s' where task_agent='%s' and task_id='%s' " % (rwmc, rwms, circle, start_time, state, username, datetime.datetime.now().strftime("%Y%m%d%H%M%S"), select_module, zjid, id )
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
           
        log.info( "rwxx", "任务编辑sql【%s】", sql )
        if cur.rowcount == 1:
            log.info( "rwxx", "任务编辑成功！" )
            content['xym'] = '000000'
            content['xyxx'] = '任务编辑成功！'
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "rwxx", '任务编辑失败')
            
            content['xyxx'] = '任务编辑失败！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[task_edit_view]执行错误:%s' % str( e )
        log.exception( 'rwxx', '后台函数[task_edit_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )