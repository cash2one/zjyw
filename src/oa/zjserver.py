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
import sys
reload(sys)
sys.setdefaultencoding('utf8')

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
        log.info( "zjserver", '主机ID【%s】，密文串【%s】', zjid, encrypt_str)
        with myapi.connection() as con:
            cur = con.cursor()
            sql = "select agent_code from AgentInfo where agent_id='%s'" % zjid
            log.info( "zjserver", '查询主机密码的sql: %s',sql )
            cur.execute(sql)
            rs = cur.fetchone()
            if rs:
                mm = rs[0]
            else:
                content['response_code'] = '99'
                content['response_info'] = '查询失败，主机ID不存在'
                log.info( "zjserver", '查询失败，主机ID不存在,主机ID【%s】', zjid )
                return HttpResponse( json.dumps( content) , content_type='application/json' )
        mw = rand[:4] + '-' + rand[4:] + '-' + mm[:4] + '-' + mm[4:]
        log.info( "zjserver", '根据主机ID组成的明文：%s',mw )
        import hashlib
        encrypt = hashlib.md5(mw).hexdigest().upper()
        log.info( "zjserver", '本地生成的密文：%s',encrypt )
        if encrypt_str != encrypt[:16]:
            content['response_code'] = '99'
            content['response_info'] = '查询失败，主机ID验密失败'
            log.info( "zjserver", '查询失败，主机ID验密失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        log.info( "zjserver", '密文验证通过：请求密文【%s】,本地密文【%s】',encrypt_str, encrypt[:16] )
        ls=[]
        # 查询主机任务信息 task_type":1,"task_id":2, "task_module":"http://xxx/xxx", "task_circle":2, "task_start_time":"3-10:10:10"
        # task_state任务状态 0：未执行，1：等待运行，2：停止运行,9：已执行
        # 周期性的任务只要代理请求查询就下发，不需要管理任务运行状态，杭小勇那边负责，一次性的任务我这边需要根据task_circle来实时更新任务状态
        sql = "select task_id, task_type, b.module_name as task_module, task_circle, task_start_time from AgentTask a, TaskModuleInfo b where task_agent='%s' and task_state='1' and a.task_module=b.module_id " % zjid
        log.info( "zjserver", '查询任务信息的sql:%s', sql)
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                dic = rs.to_dict()
                ls.append(dic)
        for l in ls:
            # 只有周期为每月的情况下start_time是标准日期
            if circle == '3': # 每月一次
                t_time = start_time.split(' ')
                start_time = t_time[0][8:] + '-' + t_time[1][:5] + ':00'
            l['datetime'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        # 15:16 2016/7/20 经与杭小勇商讨，给他下发空结果集也没事，他那边都能处理，不需要判断是什么原因导致的空结果集
        with myapi.connection() as con:
            cur = con.cursor()
            # 只更新task_circle为0一次性的任务 task_state:1-等待执行
            sql_upd = "update AgentTask set task_state='9' where task_agent='%s' and task_state='1' and task_circle='0'"% zjid
            log.info( "zjserver", '更新任务信息表的任务状态的sql:%s', sql_upd)
            cur.execute( sql_upd )
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
        请求信息格式：cookie:{“agent_id”:”1000-0001-2946-4832-C7FC-20CB-33D7-363B”} 如果与任务模板有关的告警需要上送任务ID
        告警信息：先按照每次请求上送一条告警信息传送
        { ”alarms”:[{ ” warn_detail”:”内存不足告警”, ” warn_level”:”2”, ” warn_time_join”:”2016-07-08 09:46:30”,”warn_suggest”:”建议清除多余的文件”,”warn_type”:”4”,},………] }
    """
    try:
        req_dic = request.META.get('HTTP_COOKIE')
        req = eval( req_dic )
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
        log.info( "zjserver", '主机ID【%s】，密文串【%s】', zjid, encrypt_str)
        with myapi.connection() as con:
            cur = con.cursor()
            sql = "select agent_code from AgentInfo where agent_id='%s'" % zjid
            log.info( "zjserver", '查询主机密码的sql: %s',sql )
            cur.execute(sql)
            rs = cur.fetchone()
            if rs:
                mm = rs[0]
            else:
                content['response_code'] = '99'
                content['response_info'] = '查询失败，主机ID不存在'
                log.info( "zjserver", '查询失败，主机ID不存在,主机ID【%s】', zjid )
                return HttpResponse( json.dumps( content) , content_type='application/json' )
        mw = rand[:4] + '-' + rand[4:] + '-' + mm[:4] + '-' + mm[4:]
        log.info( "zjserver", '根据主机ID组成的明文：%s',mw )
        import hashlib
        encrypt = hashlib.md5(mw).hexdigest().upper()
        log.info( "zjserver", '本地生成的密文：%s',encrypt )
        if encrypt_str != encrypt[:16]:
            content['response_code'] = '99'
            content['response_info'] = '查询失败，主机ID验密失败'
            log.info( "zjserver", '查询失败，主机ID验密失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        log.info( "zjserver", '密文验证通过：请求密文【%s】,本地密文【%s】',encrypt_str, encrypt[:16] )
        
        """
        告警信息格式：先按照每次请求上送一条告警信息传送
        {'warn_level': '5', 'warn_type': 'T1000', 'warn_detail': '\xe6\xb5\x8b\xe8\xaf\x95\xe5\x91\x8a\xe8\xad\xa6', 'warn_time_join': '2016-07-19 11:29:47', 'warn_suggest': '\xe5\x8f\xaf\xe5\xbf\xbd\xe7\x95\xa5'}
        """
        lst = eval(request.body)
        with myapi.connection() as con:
            cur = con.cursor()
            sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent, warn_task )values('%s','%s','%s','1','%s','%s','%s','%s')"%(lst["warn_detail"], lst["warn_level"], lst["warn_suggest"], lst["warn_time_join"], lst["warn_type"], zjid, lst.get("task_id",'') )
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
        log.info( "zjserver", '主机ID【%s】，密文串【%s】', zjid, encrypt_str)
        with myapi.connection() as con:
            cur = con.cursor()
            sql = "select agent_code from AgentInfo where agent_id='%s'" % zjid
            log.info( "zjserver", '查询主机密码的sql: %s',sql )
            cur.execute(sql)
            rs = cur.fetchone()
            if rs:
                mm = rs[0]
            else:
                content['response_code'] = '99'
                content['response_info'] = '查询失败，主机ID不存在'
                log.info( "zjserver", '查询失败，主机ID不存在,主机ID【%s】', zjid )
                return HttpResponse( json.dumps( content) , content_type='application/json' )
        mw = rand[:4] + '-' + rand[4:] + '-' + mm[:4] + '-' + mm[4:]
        log.info( "zjserver", '根据主机ID组成的明文：%s',mw )
        import hashlib
        encrypt = hashlib.md5(mw).hexdigest().upper()
        log.info( "zjserver", '本地生成的密文：%s',encrypt )
        if encrypt_str != encrypt[:16]:
            content['response_code'] = '99'
            content['response_info'] = '查询失败，主机ID验密失败'
            log.info( "zjserver", '查询失败，主机ID验密失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        log.info( "zjserver", '密文验证通过：请求密文【%s】,本地密文【%s】',encrypt_str, encrypt[:16] )
        
        """
        {"task_id":"xxxxxxxxxx"，"scheme_time":"2016-07-14 12:00:00","result":"{"os detection": [{"检查项目": "检查是否删除或锁定与设备运行、维护等工作无关的账号", "标准值": "所有无关账号都被删除或锁定", "检查结果": "通过", "实际值": "没有发现无关用户"}……]}"}
        task_id : 任务ID
        scheme_time : 计划执行时间
        result : 体检结果
        """
        # 开始处理体检报告信息
        #log.info( "zjserver", '==================request.body===============================%s',repr(request.body) )
        
        body_dic = eval(request.body)
        #log.info( "zjserver", '==================body_dic===============================%s',repr(body_dic) )
        task_id = body_dic.get('task_id','')
        task_scheme_time = body_dic.get('scheme_time','')
        check_result = eval( body_dic.get('result','') )
        #log.info( "zjserver", '==================check_result===============================%s',repr(check_result) )
        ip_addr = check_result.get('IP_ADDR','')
        mac_addr = check_result.get('MAC_ADDR','')
        os_fullname = check_result.get('OS_FULLNAME','')
        # 获取数据库配置
        db_type = check_result.get('db_type','')
        db_str = ''
        for dbase in db_type:
            db_str += ( dbase.get('db_name') + ( dbase.get('db_version') if dbase.get('db_version') and dbase.get('db_version') != '-' else '' ) + ',' )
        log.info( "zjserver", '==================db_str===============================%s',db_str )
        # 获取中间件配置
        middleware_type = check_result.get('middleware_type','')
        middleware_str = ''
        for m in middleware_type:
            middleware_str += ( m.get('middleware_name') + ( m.get('middleware_version') if m.get('middleware_version') and m.get('middleware_version') != '-' else '' ) + ',' )
#        log.info( "zjserver", '==================middleware_str===============================%s',middleware_str )
        
        agent_report = check_result.get('os_report','')
        #log.info( "zjserver", '==================agent_report===============================%s',repr(agent_report) )
        if not agent_report:
            content['response_code'] = '14'
            content['response_info'] = '信息不完整,无告警信息'
            log.info( "zjserver", '信息不完整,无告警信息,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        
        """ 处理体检结果信息：
                体检有未通过项时,warn_level为5 warn_suggest为“建议查看体检报告明确具体项目”warn_type为S2001 warn_detail为“有体检项未通过”；
                体检有未检查项时,warn_level为5 warn_suggest为“建议查看体检报告明确具体项目及原因”warn_type为S2002 warn_detail为“有体检项未核查”
                体检有未检查项未通过项时,warn_level为5 warn_suggest为“建议查看体检报告明确具体项目及原因”warn_type为S2003 warn_detail为“有体检项未核查，未通过”
                
            体检结果信息格式：{" os_checktime":"2016-07-08 10:10:10"，"os_report": [{"检查项目": "检查是否删除或锁定与设备运行、维护等工作无关的账号", "标准值": "所有无关账号都被删除或锁定", "检查结果": "通过", "实际值": "没有发现无关用户","类型"："os_detection"}……]}
            检查结果：检查结果为“pass”、“unpass”和“uncheck”三种。"
            体检结果格式：
            {
                "task_id":"xxxxxxxxxx"，
                "scheme_time":"2016-07-14 12:00:00",
                "result": 
                    “{
                        "IP_ADDR": "10.2.46.151", 
                        "MAC_ADDR": "00:0C:29:FD:D8:9D", 
                        "OS_FULLNAME": "CentOS release 6.4 (Final)", 
                        "db_type": [
                            {"db_name": "mysql", "db_version": "5.1.73"}
                            ...
                        ], 
                        "middleware_type": [
                            {"middleware_name": "Apache", "middleware_version": "2.2.15"}
                            ...
                        ], 
                        "os_report": [
                            {"check_item": "检查是否有重复的操作系统账号", "required_config": "不应存在相同的操作系统账号", "check_result": "pass", "actual_config": "没有发现重复的用户名", "item_type": "OS-Linux-账号", "threat_level": "5"}
                            …
                        ]
                    }”
            }            
        """
        
        a, b = 0, 0
        result1 = ''
        result2 = ''
        check_lst = []
        # 组织数据结构：agent_id, task_id, scheme_time, ip_addr, mac_addr, os_fullname, db_type, middleware_type, check_item, required_config, check_result, actual_config, threat_level, first_pro, secong_pro,third_pro
        for lst in agent_report:
            first_pro, second_pro, third_pro = lst.get('item_type').split('-')
            check_lst.append([ zjid, task_id, task_scheme_time, ip_addr, mac_addr, os_fullname, db_str, middleware_str, lst.get('check_item'), lst.get('required_config'), lst.get('check_result'), lst.get('actual_config'), lst.get('threat_level'), first_pro, second_pro, third_pro ])
            if lst['check_result'] == 'unpass':
                a += 1
                result1 = '有体检项未通过'
                #log.info( "zjserver", "检测到有一条体检项未通过")
            if lst['check_result'] == 'uncheck':
                b += 1
                result2 = '有体检项未核查'
                #log.info( "zjserver", "检测到有一条体检项未检查")
        with myapi.connection() as con:
            cur = con.cursor()
            # 判断体检结果报告并插入告警信息  11:02 2016/7/6告警类型warn_type杭小勇说之后再定，先用固定值代替
            if a > 0 and b == 0 :
                sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent, warn_task )values('有体检项未通过','5','建议查看体检报告明确具体项目','1','%s','S2001','%s','%s')"%(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), zjid, task_id)
                log.info( "zjserver", "插入告警信息表--有体检项未通过--的SQL语句【%s】", type(sql) )
                cur.execute( sql )
            if b > 0  and a == 0 :
                sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent, warn_task )values('有体检项未核查','5','建议查看体检报告明确具体项目及原因','1','%s','S2002','%s','%s')"%(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), zjid, task_id)
                log.info( "zjserver", '插入告警信息表--有体检项未核查--的SQL语句【%s】', sql )
                cur.execute( sql )
            if a > 0 and b > 0: 
                sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent, warn_task )values('有体检项既未通过又未核查','5','建议查看体检报告明确具体项目及原因','1','%s','S2003','%s','%s')"%(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), zjid, task_id)
                log.info( "zjserver", '插入告警信息表--有体检项既未通过又未核查--的SQL语句【%s】', sql )
                cur.execute( sql )
            # 通过判断result是否有值，判断检查结果task_result是哪种情况--通过、有体检项未通过、有体检项未核查、有体检项未通过并且有体检项未核查
            # 体检更新：task_scheme_time, task_real_time, task_result
            result = (result1+"并且"+result2) if result1 and result2 else result1 if result1 else result2 if result2 else '通过'
#            log.info( "zjserver", '=================result========================【%s】', result )
            sql = "update AgentTask set task_result='%s' , task_real_time='%s', task_scheme_time='%s' where task_id='%s' and task_agent='%s' "%( result, datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), task_scheme_time, task_id, zjid)
            #log.info( "zjserver", '插入体检报告信息的SQL语句【%s】', sql )
            # 更新主机状态：是否安全  00安全  01不安全
            sql_zjxx = "update AgentInfo set agent_state='%s' where agent_id='%s' "%( "00" if result=='通过' else "01", zjid )
            log.info( "zjserver", '更新主机是否安全的状态的SQL语句【%s】', sql_zjxx )
            cur.execute( sql )
            cur.execute( sql_zjxx )
            # 插入体检报告信息
            # {"check_item": "检查是否有重复的操作系统账号", "required_config": "不应存在相同的操作系统账号", "check_result": "pass", "actual_config": "没有发现重复的用户名", "item_type": "OS-Linux-账号", "threat_level": "5"}
            sql_check = "insert into CheckInfo(agent_id, task_id, scheme_time, ip_addr, mac_addr, so_fullname, db_type, middleware_type, check_item, required_config, check_result, actual_config, threat_level, first_pro, second_pro,third_pro)values( %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s )"
            log.info( "zjserver", '插入主机体检明细信息的SQL语句【%s】', sql_check )
            cur.executemany( sql_check, check_lst )
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

def host_view(request):
    """
    功能：
        主机信息接收
    描述：
        请求的报文格式：主机采集脚本的样本数据(json格式):{"HARDWARE": "i686", "platform": "Linux", "LINUX_VERSION": "CentOS", "OS_FULLNAME": "CentOS release 6.4 (Final)", "OS_KERNELVERSION": "2.6.32", "IP_ADDR": "10.2.46.151", "MAC_ADDR": "00:0C:29:FD:D8:9D","HOST_NAME": "localhost"}
        响应的报文格式：{"response_code":1,"response_info":"asdfaf"}
    """
    try:
        content={}
        ls=[]
        req_dic = request.META.get('HTTP_COOKIE')
        req = eval( req_dic )
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
        log.info( "zjserver", '主机ID【%s】，密文串【%s】', zjid, encrypt_str)
        with myapi.connection() as con:
            cur = con.cursor()
            sql = "select agent_code from AgentInfo where agent_id='%s'" % zjid
            log.info( "zjserver", '查询主机密码的sql: %s',sql )
            cur.execute(sql)
            rs = cur.fetchone()
            if rs:
                mm = rs[0]
            else:
                content['response_code'] = '99'
                content['response_info'] = '查询失败，主机ID不存在'
                log.info( "zjserver", '查询失败，主机ID不存在,主机ID【%s】', zjid )
                return HttpResponse( json.dumps( content) , content_type='application/json' )
        mw = rand[:4] + '-' + rand[4:] + '-' + mm[:4] + '-' + mm[4:]
        log.info( "zjserver", '根据主机ID组成的明文：%s',mw )
        import hashlib
        encrypt = hashlib.md5(mw).hexdigest().upper()
        log.info( "zjserver", '本地生成的密文：%s',encrypt )
        if encrypt_str != encrypt[:16]:
            content['response_code'] = '99'
            content['response_info'] = '查询失败，主机ID验密失败'
            log.info( "zjserver", '查询失败，主机ID验密失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        log.info( "zjserver", '密文验证通过：请求密文【%s】,本地密文【%s】',encrypt_str, encrypt[:16] )
        
        # 开始获取请求信息
        req_body = eval(request.body)
        # 获取主机信息更新：agent_name, agent_system, agent_ip, agent_mac
        #举例： {u'{"HARDWARE": "i686", "platform": "Linux", "LINUX_VERSION": "CentOS", "OS_FULLNAME": "CentOS release 6.4 (Final)", "OS_KERNELVERSION": "2.6.32", "IP_ADDR": "10.2.46.151", "MAC_ADDR": "00:0C:29:FD:D8:9D", "HOST_NAME": "localhost"}\n': [u'']}
        agent_name = req_body.get("HOST_NAME")
        agent_system = req_body.get("OS_FULLNAME")
        agent_ip = req_body.get("IP_ADDR")
        agent_mac = req_body.get("MAC_ADDR")

        # 更新主机信息
        sql = "update AgentInfo set agent_name='%s', agent_system='%s', agent_ip='%s', agent_mac='%s' where agent_id='%s'" % ( agent_name, agent_system, agent_ip, agent_mac, zjid )
        log.info( "zjserver", '更新主机信息的sql:%s', sql)
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute( sql )

        if cur.rowcount != 1:
            content['response_code'] = '99'
            content['response_info'] = '更新主机信息失败'
            log.info( "zjserver", '更新主机信息失败,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
        else:
            content['tasks'] = ls
            content['response_code'] = '00'
            content['response_info'] = '更新主机信息成功'
            log.info( "zjserver", '更新主机信息成功,主机ID【%s】', zjid )
            return HttpResponse( json.dumps( content) , content_type='application/json' )
            
    except Exception, e :
        content['response_code'] = '99'
        content['response_info'] = '更新主机信息失败'
        log.exception( 'zjserver', '后台函数[task_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )