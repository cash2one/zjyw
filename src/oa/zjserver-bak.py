# coding: utf8
# 功能描述 ：  任务信息展示及任务定制
# 作　　者 ：  成德功
# 日　　期 ：  2016/7/4
# 版　　本 ：  V1.00
# 更新履历 ：  V1.00 2016/7/4 成德功 创建.
from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.template.loader import render_to_string
import os, json, datetime
from zjyw_utils import *

log.init_log( 'zjserver' , True )


def task_view(request):
    """
    功能：
        任务查询
    描述：
        请求的报文格式：cookie:{“agent_id”:”1000-0001-2946-4832-C7FC-20CB-33D7-363B”}
        响应的报文格式：{"response_code":1,"response_info":"asdfaf", "tasks":[{"task_type":1,"task_id":2, "task_module":"http://xxx/xxx", "task_circle":2, "task_start_time":"3-10:10:10"}, {"task_type":1, "task_id":2, "task_module":"http://xxx/xxx", "task_circle":2, "task_start_time":"3-10:10:10"}, {"task_type":1, "task_id":2, "task_module":"http://xxx/xxx", "task_circle":2, "task_start_time":"3-10:10:10"}]}
    """
    try:
        req_dic = request.META.get('HTTP_COOKIE')
        req = eval( req_dic )
        log.info( "zjserver", '==================req[ agent_id ]===============================%s',req[ 'agent_id' ] )
        log.info( "zjserver", '==================req.get( agent_id)===============================%s',req.get( 'agent_id' ) )
        content={}
        ls=[]
        if not req[ 'agent_id' ]:
            content['response_code'] = '14'
            content['response_info'] = '信息不完整,主机ID错误'
            log.info( "zjserver", '信息不完整,主机ID错误,主机ID【%s】', req[ 'agent_id' ] )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        str = req[ 'agent_id' ]
        str_lst = str.split("-")
        zjid = str_lst[0]+str_lst[1]
        rand = str_lst[2]+str_lst[3]
        encrypt_str = str_lst[4]+str_lst[5]+str_lst[6]+str_lst[7]
        log.info( "zjserver", '==============encrypt_str==============%s',encrypt_str )
        log.info( "zjserver", '主机ID【%s】，密文串【%s】', zjid, encrypt_str)
        with myapi.connection() as con:
            log.info( "zjserver", '==============zjid==============%s',zjid )
            cur = con.cursor()
            sql = "select agent_code from AgentInfo where agent_id='%s'" % zjid
            log.info( "zjserver", '==============sql==============%s',sql )
            cur.execute(sql)
            rs = cur.fetchone()
            if rs:
                mm = rs[0]
                log.info( "zjserver", '==============mm==============%s',mm )
            else:
                content['response_code'] = '99'
                content['response_info'] = '查询失败，主机ID不存在'
                log.info( "zjserver", '查询失败，主机ID不存在,主机ID【%s】', zjid )
                return HttpResponse( json.dumps( content) , content_type='application/json' )
        mw = rand[:4] + '-' + rand[4:] + '-' + mm[:4] + '-' + mm[4:]
        log.info( "zjserver", '==============mw==============%s',mw )
        import hashlib
        encrypt = hashlib.md5(mw).hexdigest().upper()
        log.info( "zjserver", '============================%s',encrypt )
        if encrypt_str != encrypt[:16]:
            content['response_code'] = '99'
            content['response_info'] = '查询失败，主机ID验密失败'
            log.info( "zjserver", '查询失败，主机ID验密失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        log.info( "zjserver", '密文验证通过：请求密文【%s】,本地密文【%s】',encrypt_str, encrypt[:16] )
        ls=[]
        # 查询单个主机任务信息 task_type":1,"task_id":2, "task_module":"http://xxx/xxx", "task_circle":2, "task_start_time":"3-10:10:10"
        # task_state任务状态 0：未执行，1：等待运行，2：停止运行,9：已执行
        sql = "select task_id, task_type, task_module, task_circle, task_time, task_week, task_day, task_start_time from AgentTask where task_agent='%s' and task_state='1'" % zjid
        log.info( "zjserver", '===========sql==================%s', sql)
#        # 查询所属主机组的任务信息
#        #sql = "select task_id, a.task_type, a.task_module, a.task_circle, a.task_start_time from AgentTask a where a.task_group is not null and a.task_state='2' and '%s' in (select replace(b.group_agent,'|',',') from AgentGroupInfo b where b.group_id=a.task_group )" % zjid
#        sql1 = "select b.group_agent as group_agent from AgentTask a,AgentGroupInfo b where b.group_id=a.task_group group by b.group_id"
#        log.info( "zjserver", '===========sql1==================%s', sql1)
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                dic = rs.to_dict()
                ls.append(dic)
            log.info( "zjserver", '===========ls==================%s',ls )
        for l in ls:
            if l['task_circle'] == '1':
                l['task_start_time'] = l['task_time']
            elif l['task_circle'] == '2':
                l['task_start_time'] = l['task_week']+'-'+l['task_time']
            else:
                l['task_start_time'] = l['task_day']+'-'+l['task_time']
            
#            rs1 = myapi.sql_execute(cur, sql1)
#            log.info( "zjserver", '===========rs1==================%s',rs1 )
#            while rs1.next():
#                dic1 = rs1.to_dict()
#                ls.append(dic1)
#            log.info( "zjserver", '=====zj======ls==================%s',ls )
#            for l in ls:
#                sql2 = "select task_id, a.task_type as task_type, a.task_module as task_module, a.task_circle as task_circle, a.task_start_time as task_start_time from AgentTask a where a.task_agent in %s and a.task_group is not null and a.task_state='2' and a.task_agent='%s'" % ( (repr(tuple(l['group_agent'].split(','))) if len(l['group_agent'])!=8 else "(%s)"%l[0]), zjid )
#                log.info( "zjserver", '===========sql2==================%s', sql2)
#                rs2 = myapi.sql_execute(cur, sql2)
#                while rs2.next():
#                    dic2 = rs2.to_dict()
#                    ls_rwxx.append(dic2)
#            log.info( "zjserver", '======group=====ls==================%s', ls)
        if not ls:
            content['response_code'] = '99'
            content['response_info'] = '查询失败'
            log.info( "zjserver", '查询失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        else:
            content['tasks'] = ls
            content['response_code'] = '00'
            content['response_info'] = '查询成功'
            log.info( "zjserver", '查询成功,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
            
    except Exception, e :
        content['response_code'] = '99'
        content['response_info'] = '查询失败'
        log.exception( 'zjserver', '后台函数[task_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

def alarm_view(request):
    """
    功能：
        告警信息上送
    描述：
        请求信息格式：cookie:{“agent_id”:”1000-0001-2946-4832-C7FC-20CB-33D7-363B”} 如果与任务模板有关的告警需要上送模板ID
        告警信息：先按照每次请求上送一条告警信息传送
        { ”alarms”:[{ ” warn_detail”:”内存不足告警”, ” warn_level”:”2”, ” warn_time_join”:”2016-07-08 09:46:30”,”warn_suggest”:”建议清除多余的文件”,”warn_type”:”4”,},………] }

    """
    try:
        req_dic = request.META.get('HTTP_COOKIE')
        req = eval( req_dic )
        content={}
        ls=[]
        if not request.COOKIES[ 'agent_id' ]:
            content['response_code'] = '14'
            content['response_info'] = '信息不完整,主机ID错误'
            log.info( "zjserver", '信息不完整,主机ID错误,主机ID【%s】', request.COOKIES[ 'agent_id' ] )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        str = request.COOKIES[ 'agent_id' ]
        str_lst = str.split("-")
        zjid = str_lst[0]+str_lst[1]
        rand = str_lst[2]+str_lst[3]
        encrypt_str = str_lst[4]+str_lst[5]+str_lst[6]+str_lst[7]
        log.info( "zjserver", '主机ID【%s】，密文串【%s】', zjid, encrypt_str)
        with myapi.connection() as con:
            cur = con.cursor()
            sql = "select agent_code from agentinfo where agent_id='%s'" % zjid
            cur.execute(sql)
            rs = cur.fetchone()
            if rs:
                mm = rs[0]
            else:
                content['response_code'] = '99'
                content['response_info'] = '查询失败，主机ID不存在'
                log.info( "zjserver", '查询失败，主机ID不存在,主机ID【%s】', zjid )
                return HttpResponse( json.dumps( content) , content_type='application/json' )
        mw = rand + mm
        if not check_id( mw, encrypt_str ):
            content['response_code'] = '99'
            content['response_info'] = '查询失败，主机ID验密失败'
            log.info( "zjserver", '查询失败，主机ID验密失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        # 开始处理告警信息--14:43 2016/7/8经杭小勇商讨暂不上送此字段，把该信息放入告警详细中展示
        # task_id = request.COOKIES[ 'task_id' ] 
        alarm_info = request.POST.get('alarms','')
        if not alarm_info:
            content['response_code'] = '14'
            content['response_info'] = '信息不完整,无告警信息'
            log.info( "zjserver", '信息不完整,无告警信息,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        
        with myapi.connection() as con:
            cur = con.cursor()
            for lst in alarm_info:
                sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent )values('%s','%s','%s','1','%s','%s','%s')"%(lst["warn_detail"], lst["warn_level"], lst["warn_suggest"], lst["warn_time_join"], lst["warn_type"], agent_id)
                log.info( "zjserver", '插入告警信息表的SQL语句【%s】', sql )
                cur.execute( sql )
        # 返回错误信息
        content['response_code'] = '00'
        content['response_info'] = '告警信息提交成功'
        log.info( "zjserver", '告警信息提交成功,主机ID【%s】', zjid )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['response_code'] = '99'
        content['response_info'] = '后台函数[alarm_view]执行错误:%s' % str( e )
        log.exception( 'zjserver', '后台函数[alarm_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

# 体检结果
def check_view(request):
    try:
        req_dic = request.META.get('HTTP_COOKIE')
        req = eval( req_dic )
        content={}
        ls=[]
        if not request.COOKIES[ 'agent_id' ]:
            content['response_code'] = '14'
            content['response_info'] = '信息不完整,主机ID错误'
            log.info( "zjserver", '信息不完整,主机ID错误,主机ID【%s】', request.COOKIES[ 'agent_id' ] )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        str = request.COOKIES[ 'agent_id' ]
        str_lst = str.split("-")
        zjid = str_lst[0]+str_lst[1]
        rand = str_lst[2]+str_lst[3]
        encrypt_str = str_lst[4]+str_lst[5]+str_lst[6]+str_lst[7]
        log.info( "zjserver", '主机ID【%s】，密文串【%s】', zjid, encrypt_str)
        with myapi.connection() as con:
            cur = con.cursor()
            sql = "select agent_code from agentinfo where agent_id='%s'" % zjid
            cur.execute(sql)
            rs = cur.fetchone()
            if rs:
                mm = rs[0]
            else:
                content['response_code'] = '99'
                content['response_info'] = '查询失败，主机ID不存在'
                log.info( "zjserver", '查询失败，主机ID不存在,主机ID【%s】', zjid )
                return HttpResponse( json.dumps( content) , content_type='application/json' )
        mw = rand + mm
        if not check_id( mw, encrypt_str ):
            content['response_code'] = '99'
            content['response_info'] = '查询失败，主机ID验密失败'
            log.info( "zjserver", '查询失败，主机ID验密失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        
        # 开始处理体检报告信息
        task_id = request.COOKIES[ 'task_id' ] 
        agent_report = request.POST.get('os_report','')
        task_real_time = request.POST.get('os_checktime','')
        if not agent_report:
            content['response_code'] = '14'
            content['response_info'] = '信息不完整,无告警信息'
            log.info( "zjserver", '信息不完整,无告警信息,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        
        """ 处理体检结果信息：
                体检有未通过项时,warn_level为5 warn_suggest为“建议查看体检报告明确具体项目”warn_type为1 warn_detail为“有体检项未通过”；
                体检有未检查项时,warn_level为5 warn_suggest为“建议查看体检报告明确具体项目及原因”warn_type为1 warn_detail为“有体检项未核查”
                体检既有未通过项又有未检查项，上述两条都插入告警信息表
            体检结果信息格式：{" os_checktime":"2016-07-08 10:10:10"，"os_report": [{"检查项目": "检查是否删除或锁定与设备运行、维护等工作无关的账号", "标准值": "所有无关账号都被删除或锁定", "检查结果": "通过", "实际值": "没有发现无关用户","类型"："os_detection"}……]}
            检查结果：检查结果为“通过”、“未通过”和“未检查”三种。"
            检查项目":  "X1",  "标准值":  "Y1",  "检查结果":  "Z1",  "实际值":  "A1"，
        """
        a, b = 0, 0
        ls = []   # 通过判断长度判断是哪种情况  0-通过；1-不通过；2-未检查
        for lst in agent_report:
            if lst['检查结果'] == '未通过':
                a += 1
                ls.append(1)
            if lst['检查结果'] == '未检查':
                b += 1
                ls.append(2)
        
        with myapi.connection() as con:
            cur = con.cursor()
            # 判断体检结果报告并插入告警信息
            if a > 0 :
                sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent )values('有体检项未通过','5','建议查看体检报告明确具体项目','1','%s','1','%s')"%(task_real_time, agent_id)
                log.info( "zjserver", "插入告警信息表--有体检项未通过--的SQL语句【%s】", sql )
                cur.execute( sql )
            if b > 0 :
                sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent )values('有体检项未核查','5','建议查看体检报告明确具体项目及原因','1','%s','1','%s')"%(task_real_time, agent_id)
                log.info( "zjserver", '插入告警信息表--有体检项未核查--的SQL语句【%s】', sql )
                cur.execute( sql )
            
            # 插入体检报告信息
            sql = "update AgentTask set task_report='%s' and task_result='%s' and task_real_time='%s' where task_id='%s' and task_agent='%s' "%(repr(agent_report),"成功" if len(ls) == 0 else "失败", task_real_time, task_id, agent_id)
            log.info( "zjserver", '插入体检报告信息的SQL语句【%s】', sql )
            # 更新主机状态：是否安全  00安全  01不安全
            sql_zjxx = "update AgentInfo set agent_state='%s' where agent_id='%s' "%( "00" if len(ls) == 0 else "01", agent_id )
            log.info( "zjserver", '更新主机是否安全的状态的SQL语句【%s】', sql_zjxx )
            cur.execute( sql )
            cur.execute( sql_zjxx )
        
        # 返回错误信息
        content['response_code'] = '00'
        content['response_info'] = '体检报告信息提交成功'
        log.info( "zjserver", '体检报告信息提交成功,主机ID【%s】', zjid )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['response_code'] = '99'
        content['response_info'] = '后台函数[check_view]执行错误:%s' % str( e )
        log.exception( 'zjserver', '后台函数[check_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
