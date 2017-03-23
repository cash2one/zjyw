# coding: utf8
# 功能描述 ：  主机信息展示、主机ID生成及主机分组功能
# 作　　者 ：  成德功
# 日　　期 ：  2016/6/15
# 版　　本 ：  V1.00
# 更新履历 ：  V1.00 2016/6/1 成德功 创建.
from django.conf import settings
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.template.loader import render_to_string
import os, json, datetime
from zjyw_utils import *

log.init_log( 'zjxx' , True )

def zjxx_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        username = request.session.get('username','').encode('utf8')
        password = request.session.get('password','').encode('utf8')
        log.info( "zjxx", '用户【%s】已进入zjxx_view函数', username)
        sql = "select * from AgentInfo order by agent_id desc"
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_lst = rs.to_dict()
                ls.append(rs_lst)
        if ls:
            for i in ls:
                if i['agent_group']:
                    i['agent_group'] = i['agent_group'][1:]
                else:
                    i['agent_group'] =  ''
            log.info( "zjxx",  repr(ls))
            content['xym'] = '000000'
            content['cont'] = render_to_string( 'zjxx_idx.html', {'zjxx_dic':ls} )
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "zjxx", '主机信息不存在')
            content['xyxx'] = '主机信息不存在！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[zjxx_view]执行错误:%s' % str( e )
        log.exception( 'zjxx', '后台函数[zjxx_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )


# 删除主机
def zjxx_del_view(request):
    try:
        content={}
        ls=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        zjid = request.POST.get('zjid','').encode('utf8')
        # 删除
        sql = "delete from AgentInfo where agent_id='%s' " % zjid 
        with myapi.connection() as con:
            cur = con.cursor()
            cur.execute(sql)
           
        log.info( "zjxx", "主机删除sql【%s】", sql )
        if cur.rowcount == 1:
            log.info( "zjxx", "主机删除成功！" )
            content['xym'] = '000000'
            content['xyxx'] = '主机删除成功！'
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "zjxx", '主机删除失败')
            content['xyxx'] = '主机删除失败！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[zjxx_del_view]执行错误:%s' % str( e )
        log.exception( 'zjxx', '后台函数[zjxx_del_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
        
def zjxx_detail_view(request):
    try:
        log.info( "zjxx", '会话session=====================：【%s】', repr(request) )
        log.info( "zjserver", '==================request no===============================%s',repr(request.body) )
        content={}
        agent_rs_lst=[]
        task_rs_lst=[]
        check_rs_lst=[]
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        zjip = request.POST.get('zjip','').encode('utf8')
        agentinfo_sql = "select * from AgentInfo  where agent_id='%s' order by agent_id desc " % zjip
        taskinfo_sql = "select * from AgentTask  where task_agent='%s' order by task_id desc" % zjip
        checkinfo_sql = "select b.task_id, b.task_scheme_time, b.task_real_time, b.task_result, b.task_type, b.task_detail  from AgentInfo a, AgentTask b  where a.agent_id=b.task_agent and b.task_agent='%s' order by b.task_id desc" % zjip
        with myapi.connection() as con:
            cur = con.cursor()
            agentinfo_rs = myapi.sql_execute(cur, agentinfo_sql)
            while agentinfo_rs.next():
                agentinfo_lst = agentinfo_rs.to_dict()
                agent_rs_lst.append(agentinfo_lst)
                
            taskinfo_rs = myapi.sql_execute(cur, taskinfo_sql)
            while taskinfo_rs.next():
                taskinfo_rs_lst = taskinfo_rs.to_dict()
                task_rs_lst.append(taskinfo_rs_lst)
                
            checkinfo_rs = myapi.sql_execute(cur, checkinfo_sql)
            while checkinfo_rs.next():
                checkinfo_lst = checkinfo_rs.to_dict()
                check_rs_lst.append(checkinfo_lst)
        for i in agent_rs_lst:
            i['agent_group'] = i['agent_group'][1:] if i['agent_group'] else ''
        week = {'1':'一','2':'二','3':'三','4':'四','5':'五','6':'六','7':'日',}
        if task_rs_lst:
            for i in task_rs_lst:
                i['start_time'] = i['task_start_time']
                if i['task_circle'] == '1': # 每天一次
                    i['task_start_time'] = '每天'+i['task_start_time'][:2]+'点'+i['task_start_time'][3:5]+'分'+i['task_start_time'][6:]+'秒'
                if i['task_circle'] == '2': # 每周一次
                    s = i['task_start_time'].split('-')
                    i['task_start_time'] = '每周'+week[s[0]]+ s[1][:2]+'点'+s[1][3:5]+'分'+s[1][6:]+'秒'
                if i['task_circle'] == '3': # 每月一次  只有周期为每月的情况下task_start_time是标准日期 yyyy-mm-dd hh:mm:ss
                    ss = i['task_start_time'].split(' ')
                    i['task_start_time'] = '每月'+ss[0][8:]+'号'+ ss[1][:2]+'点'+ss[1][3:5]+'分'+ss[1][6:]+'秒'
        if agent_rs_lst or  task_rs_lst  or check_rs_lst:
            log.info( "zjxx", "主机信息111111：【%s】", repr(agent_rs_lst) or '' )
            log.info( "zjxx", "主机信息222222：【%s】", repr(task_rs_lst)  or '' )
            log.info( "zjxx", "体检信息333333：【%s】", repr(check_rs_lst)  or '' )
            content['xym'] = '000000'
            # 把主机ID放入会话中方便后续操作
            request.session[ 'agent_id' ] = zjip
            content['cont'] = render_to_string( "zjxx_detail.html", {"agent_rs_lst":agent_rs_lst, "task_rs_lst":task_rs_lst, "check_rs_lst":check_rs_lst} )
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "zjxx", '主机信息不存在')
            content['xyxx'] = '主机信息不存在！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[zjxx_detail_view]执行错误:%s' % str( e )
        log.exception( 'zjxx', '后台函数[zjxx_detail_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

# 主机分组
def zjfz_view(request):
    try:
        content={}
        ls = []
        ls_agent = []
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
            
        # 查询所有主机组信息
        sql = "select * from AgentGroupInfo "
        # 查询所有主机ID
        agent_sql = "select agent_id, agent_name from AgentInfo "
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_lst = rs.to_dict()
                ls.append(rs_lst)
            
            agent_rs = myapi.sql_execute(cur, agent_sql)
            while agent_rs.next():
                agent_lst = agent_rs.to_dict()
                ls_agent.append(agent_lst)
        if ls or ls_agent:
            log.info( "zjxx", "获取到的主机组信息：【%s】", repr(ls) or '' )
            log.info( "zjxx", "获取到的主机ID：【%s】", repr(ls_agent) or '' )
            dic_group = {}
            ls_group = []   #[{主机组ID1:[主机ID1,主机ID2,....]},{主机组ID2:[主机ID3,主机ID4,....]}]
            #ls_group_id = [] #[]
            for group in ls:
                group["group_agent"] = group["group_agent"]
                ls_group.append(group)
                #ls_group_id.append(group["group_id"])
            content['xym'] = '000000'
            content['cont'] = render_to_string( 'zjfz.html', {'ls_group':ls_group, 'ls_agent':ls_agent} )
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "zjxx", '主机信息不存在')
            content['xyxx'] = '主机信息不存在！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[zjfz_view]执行错误:%s' % str( e )
        log.exception( 'zjxx', '后台函数[zjfz_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

# 保存主机分组
def save_zjfz_view(request):
    try:
        content={}
        ls = []
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        zj = request.POST.get('zj','').encode('utf8')
        zjz = request.POST.get('zjz','').encode('utf8')
        zj = zj[:-1].replace(',','|')
        zj_lst = zj.split('|')
        # 查询是否存在主机组信息
        sql = "select group_agent from AgentGroupInfo where group_name='%s'" % zjz
        log.info( "zjxx", "查询是否有重复的主机组信息sql：【%s】", sql )
        # 新增的主机组信息
        agent_sql = "insert into  AgentGroupInfo(group_id, group_name, group_agent)values(nextval('group_id'),'%s','%s')" % (zjz,zj)
        log.info( "zjxx", "保存主机组信息sql：【%s】", agent_sql )
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_lst = rs.to_dict()
                ls.append(rs_lst)
            if ls:
                """ 目前主机分组只是新增主机组时的处理，已存在的主机组内的主机发生变化时的处理尚未实现TODO
                  1、根据主机组查询原先包含的主机列表
                  2、新的主机列表与原先的做差，方法是：[ i for i in a if i not in b ]；然后得到的结果集是要删除的任务信息，新的主机列表中的主机要循环更新或新增到任务信息表中
                  注：经杭小勇确认，主机单独的任务与主机所属主机组的任务是可以并存的
                """
                log.info( "zjxx", "获取到的主机组信息：【%s】", repr(ls) or '' )
                zj_lst_old = ls[0]['group_agent'].split('|')
                # 新的主机组列表与原先的做差
                ret = [ i for i in zj_lst_old if i not in zj_lst ]
                if ret: # 说明是减少主机了
                    # 更新主机信息表中的 主机组信息
                    for agent in ret:
                        sel_sql = "select agent_group from AgentInfo where agent_id='%s'" % agent
                        cur.execute( sel_sql )
                        rs_group = cur.fetchone()
                        if rs_group:
                            # 找出之前的主机信息列表中该主机所属的所有主机组的信息
                            group_lst_old = rs_group[0].split('|')
                            if zjz in group_lst_old:
                                group_lst_old.remove(zjz)
                                group_lst_new = '|'.join(group_lst_old)
                            else:
                                group_lst_new = '|'.join(group_lst_old)
                            upd_sql = "update AgentInfo set agent_group='%s' where agent_id='%s'" % (group_lst_new, agent)
                            cur.execute( upd_sql )
                        # 更新主机组信息表中的主机
                        sel_sql = "select group_agent from AgentGroupInfo where group_name='%s'" % zjz
                        cur.execute( sel_sql )
                        rs_agent = cur.fetchone()
                        if rs_agent:
                            agent_lst_old = rs_agent[0].split('|')
                            if agent in agent_lst_old:
                                agent_lst_old.remove(agent)
                                agent_lst_new = '|'.join(agent_lst_old)
                            else:
                                agent_lst_new = '|'.join(agent_lst_old)
                            upd_sql = "update AgentGroupInfo set group_agent='%s' where group_name='%s'" % (agent_lst_new, zjz)
                            cur.execute( upd_sql )
                            
                ret = [ i for i in zj_lst if i not in zj_lst_old ]
                if ret: # 说明新增主机了
                    # 更新主机信息表中的 主机组信息
                    for agent in ret:
                        sel_sql = "select agent_group from AgentInfo where agent_id='%s'" % agent
                        cur.execute( sel_sql )
                        rs_group = cur.fetchone()
                        if rs_group:
                            # 找出之前的主机信息列表中该主机所属的所有主机组的信息
                            group_lst_old = rs_group[0].split('|')
                            if zjz not in group_lst_old:
                                group_lst_old.append(zjz)
                                group_lst_new = '|'.join(group_lst_old)
                            else:
                                group_lst_new = '|'.join(group_lst_old)
                            upd_sql = "update AgentInfo set agent_group='%s' where agent_id='%s'" % (group_lst_new, agent)
                            cur.execute( upd_sql )
                        else:
                            upd_sql = "update AgentInfo set agent_group='%s' where agent_id='%s'" % (zjz, agent)
                            cur.execute( upd_sql )
                        # 更新主机组信息表中的主机
                        sel_sql = "select group_agent from AgentGroupInfo where group_name='%s'" % zjz
                        cur.execute( sel_sql )
                        rs_agent = cur.fetchone()
                        if rs_agent:
                            agent_lst_old = rs_agent[0].split('|')
                            if agent not in agent_lst_old:
                                agent_lst_old.append(agent)
                                agent_lst_new = '|'.join(agent_lst_old)
                            else:
                                agent_lst_new = '|'.join(agent_lst_old)
                            upd_sql = "update AgentGroupInfo set group_agent='%s' where group_name='%s'" % (agent_lst_new, zjz)
                            cur.execute( upd_sql )
                        else:
                            upd_sql = "update AgentGroupInfo set group_agent='%s' where group_name='%s'" % (agent, zjz)
                            cur.execute( upd_sql )
                # 返回页面信息
                log.info( "zjxx", '主机分组成功，分组已更新')
                content['xym'] = '000000'
                content['xyxx'] = '主机分组成功，分组已更新！'
                return HttpResponse( json.dumps( content) , content_type='application/json' )
            else:
                # 新增的主机组
                cur.execute(agent_sql)
                if cur.rowcount == 1:
                    # 更新每个主机的所属主机组信息
                    for zjid in zj_lst:
                        sql = "select agent_group from AgentInfo where agent_id='%s'" % zjid
                        cur.execute( sql )
                        rs_zjz = cur.fetchone()
                        if rs_zjz:
                            # 找出之前的主机信息列表中该主机所属的所有主机组的信息
                            group_lst_old = rs_zjz[0].split('|')
                            if zjz not in group_lst_old:
                                group_lst_old.append(zjz)
                                group_lst_new = '|'.join(group_lst_old)
                                upd_sql = "update AgentInfo set agent_group='%s' where agent_id='%s'" % (group_lst_new, zjid)
                                cur.execute( upd_sql )
                        else:
                            sql = "update AgentInfo set agent_group='%s' where agent_id='%s'" % ( zjz, zjid )
                            cur.execute(sql)
                # 新增主机分组信息
                log.info( "zjxx", '主机分组成功，新增主机组: %s' % zjz )
                content['xym'] = '000000'
                content['xyxx'] = '主机分组成功，新增主机组: %s' % zjz 
                return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[save_zjfz_view]执行错误:%s' % str( e )
        log.exception( 'zjxx', '后台函数[save_zjfz_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
        
# 主机id生成
def zjid_view(request):
    try:
        content={}
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        log.info( "zjxx", "自动生成的主机ID的页面跳转")
        content['xym'] = '000000'
        content['cont'] = render_to_string( 'zjid.html', {} )
        return HttpResponse( json.dumps( content), content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[zjid_view]执行错误:%s' % str( e )
        log.exception( 'zjxx', '后台函数[zjid_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )
        
# 主机id生成
def zjid_made_view(request):
    try:
        content={}
        content['xym'] = '0'
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        # 主机组是固定的20个组，页面上可以操作的仅仅是主机
        # 查询所有主机序列，获取自动生成的主机ID
        sql = "select nextval('agent_id') as agent_id "
        sql_mm = "select nextval('agent_mm') as agent_mm "
        with myapi.connection() as con:
            cur = con.cursor()
            rs = myapi.sql_execute(cur, sql)
            while rs.next():
                rs_dic = rs.to_dict()
            rs_mm = myapi.sql_execute(cur, sql_mm)
            while rs_mm.next():
                rs_mm_dic = rs_mm.to_dict()
        if rs_dic and rs_mm_dic:
            log.info( "zjxx", "自动生成的主机ID：【%s】", repr(rs_dic) or '' )
            content['agent_id'] = rs_dic['agent_id']
            content['agent_mm'] = rs_mm_dic['agent_mm']
            with myapi.connection() as con:
                cur = con.cursor()
                # 获取主机信息更新：agent_name, agent_system, agent_ip, agent_mac
                # 主机分组更新：agent_group, 
                # 任务定制更新：agent_task, 
                # 主机基本信息插入：agent_id, agent_code, agent_state, agent_user, agent_date_joined, agent_joiner
                sql = "insert into AgentInfo( agent_id, agent_code, agent_state, agent_user, agent_date_joined, agent_joiner ) values( '%s', '%s', '00', '%s', '%s', '%s' )"%( content['agent_id'], content['agent_mm'], request.session.get('username'), datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), request.session.get('username') )
                log.info( "zjxx", "插入主机基本信息的sql：【%s】", sql )
                cur.execute(sql)
            content['xym'] = '000000'
            return HttpResponse( json.dumps( content), content_type='application/json' )
        else:
            # 返回错误信息
            log.info( "zjxx", '主机信息不存在')
            content['xyxx'] = '主机信息不存在！'
            return HttpResponse( json.dumps( content) , content_type='application/json' )
    except Exception, e :
        content['xyxx'] = '后台函数[zjid_view]执行错误:%s' % str( e )
        log.exception( 'zjxx', '后台函数[zjid_view]执行错误:%s', str( e ) )
        return HttpResponse( json.dumps( content) , content_type='application/json' )

from  const import danger_dic, zq
# 组织数据结构展示体检信息
def zjxx_checkinfo_view(request):
    try:
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        username = request.session.get('username').encode('utf8')
        zjid = request.session.get('agent_id').encode('utf8')
        task_id = request.GET.get('task_id').encode('utf8')
        log.info( "zjxx", '要查询体检报告的主机是：%s, 任务ID是：%s', zjid, task_id )
        
        # 开始组织数据结构
        ls1, ls2, ls3, ls4, ls_zjs, rs_count, ls5, ls6, lst6, lst6_pro,lst_db, lst_mid, ls_fst_pro, ls_sec_pro, ls_zjfb_count,ls_zjfb_count,ls_zjfb_count = [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], [], []
        rs3_dic, date_dic, dic6, dic6_pro = {}, {}, {}, {}
        # 查询体检时间
        sql_0 = "select scheme_time from CheckInfo where task_id='%s'" % task_id
        # 查询主机体检结论的信息数据
        sql_1 = "select a.task_id, a.task_name, a.task_circle, b.module_info as task_module, a.task_user_join  from AgentTask a,  TaskModuleInfo b where a.task_module = b.module_id and a.task_id='%s'" % task_id
        # 在线主机数
        sql_2 = "select distinct(agent_id) as agent_id from CheckInfo where task_id='%s'" % task_id
        # 分类主机数
        sql_zjs = "select count(distinct(agent_id)) as count ,second_pro from CheckInfo where task_id='%s' group by second_pro"% task_id
        # 没有通过基线核查的主机数
        sql_3 = "select distinct(agent_id) as agent_id  from CheckInfo where check_result='unpass' and task_id='%s'" % task_id
        # 未通过项目中,极度危害的三级项目的排名
        sql_4 = " select (@rowNum:=@rowNum+1) as orderNo ,t.agent_id, t.third_pro, t.second_pro, t.counts from (SELECT agent_id, third_pro, second_pro,count(1) AS counts FROM CheckInfo where check_result='unpass' and task_id='%s' and threat_level='5' GROUP BY third_pro order by counts desc) as t,((Select (@rowNum :=0) )) as b" % task_id
        # 未通过项目中,极度危害的三级项目的总数量
        sql_count = "select sum(aa.counts) as count  from (select (@rowNum:=@rowNum+1) as orderNo ,t.agent_id, t.third_pro, t.second_pro, t.counts from (SELECT agent_id, third_pro, second_pro,count(1) AS counts FROM CheckInfo where check_result='unpass' and task_id='%s' and threat_level='5' GROUP BY third_pro order by counts desc)t,((Select (@rowNum :=0) )) b) as aa"% task_id
        # 体检目标信息
        sql_5 = "select distinct agent_id,  ip_addr, mac_addr, os_fullname, db_type, middleware_type, scheme_time from CheckInfo where task_id='%s'" % task_id
        # 主机核查项目分布

        dic_fst_pro, dic_sec_pro = {}, {}
        sql_zjfb_count = "select agent_id, count(distinct(third_pro)) as third_pro_count,count(distinct(check_item)) as check_item_count from CheckInfo  where task_id='%s' group by agent_id"% task_id
        sql_zjfb_fst_pro = "select distinct first_pro,agent_id from CheckInfo where task_id='%s' "% task_id
        sql_zjfb_sec_pro = "select distinct second_pro, agent_id from CheckInfo where task_id='%s' "% task_id
        # 主机核查结果统计
        sql_6 = "select  agent_id, count(check_item) as pass_count from CheckInfo where check_result='pass' and task_id='%s' group by agent_id" % task_id
        sql_7 = "select agent_id, count(check_item) as unpass_count from CheckInfo where check_result='unpass' and task_id='%s' group by agent_id" % task_id
        sql_8 = "select agent_id, count(check_item) as uncheck_count from CheckInfo where check_result='uncheck' and task_id='%s' group by agent_id" % task_id
        # 主机不合格项目分布
        sql_9 = "select agent_id, count(second_pro) as count , second_pro from CheckInfo where check_result='unpass' and task_id='%s'group by second_pro"% task_id
        
        # 未通过项目中,三级项目的排名
        sql_10 = " select (@rowNum:=@rowNum+1) as orderNo ,t.agent_id, t.threat_level, t.third_pro, t.second_pro, t.counts from (SELECT agent_id, threat_level, third_pro, second_pro,count(1) AS counts FROM CheckInfo where check_result='unpass' and task_id='%s' GROUP BY third_pro order by counts desc) as t,((Select (@rowNum :=0) )) as b  limit 3" % task_id
        # 查询未通过的三级项目的总数量
        sql_count_third = "select sum(aa.counts) as count  from (select (@rowNum:=@rowNum+1) as orderNo ,t.agent_id, t.third_pro, t.second_pro, t.counts from (SELECT agent_id, third_pro, second_pro,count(1) AS counts FROM CheckInfo where check_result='unpass' and task_id='%s' GROUP BY third_pro order by counts desc)t,((Select (@rowNum :=0) )) b) as aa"% task_id
        # 未通过项目中,四级项目的排名
        sql_11 = " select (@rowNum:=@rowNum+1) as orderNo ,t.agent_id, t.threat_level, t.check_item, t.second_pro, t.counts from (SELECT agent_id, threat_level, check_item, second_pro,count(1) AS counts FROM CheckInfo where check_result='unpass' and task_id='%s' GROUP BY third_pro order by counts desc) as t,((Select (@rowNum :=0) )) as b  limit 3" % task_id
        # 查询未通过的三级项目的总数量
        sql_count_fourth = "select sum(aa.counts) as count  from (select (@rowNum:=@rowNum+1) as orderNo ,t.agent_id, t.check_item, t.second_pro, t.counts from (SELECT agent_id, check_item, second_pro,count(1) AS counts FROM CheckInfo where check_result='unpass' and task_id='%s' GROUP BY third_pro order by counts desc)t,((Select (@rowNum :=0) )) b) as aa"% task_id
        
        # 所有的极度危害的未通过的三级项目
        sql_12 = " SELECT third_pro, count(1) AS unpass_count FROM CheckInfo where threat_level='5' and check_result='unpass' and task_id='%s' GROUP BY third_pro" % task_id
         # 所有的极度危害的通过的三级项目
        sql_13 = "SELECT third_pro, count(1) AS pass_count FROM CheckInfo where threat_level='5' and check_result='pass' and task_id='%s' GROUP BY third_pro " % task_id
        # 所有的极度危害的三级项目
        sql_14 = "select (@rowNum:=@rowNum+1) as orderNo , t.third_pro, t.second_pro from (SELECT third_pro, second_pro,count(1) AS counts FROM CheckInfo where threat_level='5' and task_id='%s' GROUP BY third_pro order by counts desc)t,((Select (@rowNum :=0) )) b"% task_id
        # 所有的极度危害的三级项目的总数量
        sql_15 = "SELECT count(1) AS counts FROM CheckInfo where threat_level='5' and task_id='%s'"% task_id
        
        # 所有的极度危害的未通过的四级项目
        sql_16 = " SELECT check_item, count(1) AS unpass_count FROM CheckInfo where threat_level='5' and check_result='unpass' and task_id='%s' GROUP BY check_item" % task_id
         # 所有的极度危害的通过的四级项目
        sql_17 = "SELECT check_item, count(1) AS pass_count FROM CheckInfo where threat_level='5' and check_result='pass' and task_id='%s' GROUP BY check_item " % task_id
        # 所有的极度危害的四级项目
        sql_18 = "select (@rowNum:=@rowNum+1) as orderNo , t.check_item, t.second_pro from (SELECT check_item, second_pro,count(1) AS counts FROM CheckInfo where threat_level='5' and task_id='%s' GROUP BY third_pro order by counts desc)t,((Select (@rowNum :=0) )) b"% task_id
        
        # 主机体检详细信息
        sql_tjxx = "select distinct(agent_id) as agent_id, task_id, scheme_time, ip_addr, mac_addr, os_fullname, db_type, middleware_type  from CheckInfo where task_id='%s' group by agent_id" % task_id
        """sql_4结果集形式如下：
        +---------+----------+------------------+------------+--------+
        | orderNo | agent_id | third_pro        | second_pro | counts |
        +---------+----------+------------------+------------+--------+
        |       1 | 10000001 | 口令             | Linux      |   2763 |
        |       2 | 10000001 | 远程登录         | Linux      |   2761 |
        |       3 | 10000001 | 系统Banner设置   | Linux      |    921 |
        |       4 | 10000001 | 日志             | Linux      |    921 |
        |       5 | 10000001 | 登录超时时间设置 | Linux      |    921 |
        |       6 | 10000001 | 账号             | Linux      |    921 |
        |       7 | 10000001 | FTP设置          | Linux      |    920 |
        +---------+----------+------------------+------------+--------+
        任务周期:0-一次性，1-每天一次，2-每周一次，3-每月一次，4-每季度一次，5-每年一次
        ================ls1====================[{'task_circle': '1', 'task_module': '\xe5\x85\xa8\xe9\xa1\xb9\xe7\x9b\xae\xe4\xbd\x93\xe6\xa3\x80', 'task_name': '\xe5\x9f\xba\xe4\xba\x8e\xe5\xb7\xa5\xe4\xbf\xa1\xe9\x83\xa8\xe5\x9f\xba\xe7\xba\xbf\xe7\x9a\x84\xe4\xbd\x93\xe6\xa3\x80\xe4\xbb\xbb\xe5\x8a\xa1'}]
        ==================ls2==================[{'agent_id': '10000001'}]
        ===================ls3=================[{'agent_id': '10000001'}]
        ==================ls4==================[{'orderno': 1.0, 'third_pro': '\xe5\x8f\xa3\xe4\xbb\xa4', 'counts': 2763L, 'second_pro': 'Linux', 'agent_id': '10000001'}, {'orderno': 2.0, 'third_pro': '\xe8\xb4\xa6\xe5\x8f\xb7', 'counts': 921L, 'second_pro': 'Linux', 'agent_id': '10000001'}]
        =======rs_count_lst========================{'sum(aa.counts)': Decimal('3684')}
        模板：
        XX年XX月XX日，对（任务名称）进行了主机体检，其中任务类型为（周期），体检模板为（体检模板）。<br>
          体检涉及（在线主机数）台主机，其中（linux） XX台，（windows）XX台……。<br>
          通过此次主机体检，发现共XX台主机没有通过基线核查，主机ID分别为（主机ID）…。
          未通过项目中，（linux）中（口令）排名第一,危害程度为（极度危害）；（mysql）中（口令）排名第二,危害程度为（极度危害）；……..。<br>
          极度危害的项目中，（linux）中（口令）未通过比例为（未通过的比例）
        """
        with myapi.connection() as con:
            cur = con.cursor()
            # 查询体检时间
            cur.execute(sql_0)
            rs0 = cur.fetchone()
            if not rs0:
                log.info( "zjxx", "体检报告未查询到，任务ID是【%s】" % task_id )
                no_result = {'ms':'无相关体检信息'}
                return render_to_response( 'check_info.html', {'no_result': no_result} )
            log.info( "zjxx", "================主机体检时间rs0====================%s"%repr(rs0) )
            dat = rs0[0].split(' ')
            ls = dat[0].split('-')
            date_dic['year'] = ls[0]
            date_dic['month'] = ls[1]
            date_dic['day'] = ls[2]
            log.info( "zjxx", "================主机体检时间====================%s"%repr(dat) )
            # 查询主机体检结论的信息数据
            rs1 = myapi.sql_execute(cur, sql_1)
            while rs1.next():
                rs1_lst = rs1.to_dict()
                ls1.append(rs1_lst)
            log.info( "zjxx", "================ls1查询主机体检结论的信息数据====================%s"%repr(ls1) )
            # 在线主机数
            rs2 = myapi.sql_execute(cur, sql_2)
            while rs2.next():
                rs2_lst = rs2.to_dict()
                ls2.append(rs2_lst)
            ls2[0]['count'] = len(ls2)
            log.info( "zjxx", "==================ls2在线主机数==================%s"%repr(ls2) )
            # 分类主机数
            rs_zjs = myapi.sql_execute(cur, sql_zjs)
            while rs_zjs.next():
                rs_zjs_lst = rs_zjs.to_dict()
                ls_zjs.append(rs_zjs_lst)
            log.info( "zjxx", "==================rs_zjs分类主机数==================%s"%repr(ls_zjs) )
            # 没有通过基线核查的主机数
            rs3 = myapi.sql_execute(cur, sql_3)
            while rs3.next():
                rs3_lst = rs3.to_dict()
                ls3.append(rs3_lst)
            ls2[0]['unpass_cnt'] = len(ls3)
            log.info( "zjxx", "===================ls3没有通过基线核查的主机数=================%s"%repr(ls3) )
            log.info( "zjxx", "===================ls2====================%s"%repr(ls2) )
            # 未通过项目中,极度危害的三级项目的排名
            rs4 = myapi.sql_execute(cur, sql_4)
            while rs4.next():
                rs4_lst = rs4.to_dict()
                ls4.append(rs4_lst)
            for l in ls4:
                l['orderno'] = str(int(l['orderno']))
            log.info( "zjxx", "==================ls4未通过项目中,极度危害的三级项目的排名==================%s"%repr(ls4) )
            # 未通过项目中,极度危害的三级项目的总数量
            rs5 = myapi.sql_execute(cur, sql_count)
            while rs5.next():
                rs_count_lst = rs5.to_dict()
                rs_count.append(rs_count_lst)
            log.info( "zjxx", "=======rs_count_lst未通过项目中,极度危害的三级项目的总数量========================%s"%repr(rs_count) )
            # 计算各极度危害项目的比例
            ls5 = ls4
            for l in ls5:
                log.info( "zjxx", "=======sssssssssscountsssssssss========================%s"%type(l['counts']) )
                log.info( "zjxx", "=======ssssssssrs_countssssssssss========================%s"%type(rs_count[0]['count']) )
                l['counts'] = "%.2f%%"%float( int(l['counts'])/rs_count[0]['count'] )
            log.info( "zjxx", "==================ls5计算各极度危害项目的比例==================%s"%repr(ls5) )
            # 体检目标信息，可能会是多个主机信息
            rs_6 = myapi.sql_execute(cur, sql_5)
            while rs_6.next():
                rs6_lst = rs_6.to_dict()
                ls6.append(rs6_lst)
            log.info( "zjxx", "=======ls6体检目标信息========================%s"%repr(ls6) )
            for l in  ls2:
                for ll in ls6:
                    if ll['agent_id'] == l['agent_id']:
                        lst_db.append(ll['db_type'])
                        lst_mid.append(ll['middleware_type'])
                        lst6.append( [ll['ip_addr'],ll['mac_addr'],ll['os_fullname'],ll['scheme_time']] )
                dic6_pro['agent_id'] = l['agent_id']
                dic6_pro['ip_addr'] = lst6[0][0]
                dic6_pro['mac_addr'] = lst6[0][1]
                dic6_pro['os_fullname'] = lst6[0][2]
                dic6_pro['scheme_time'] = lst6[0][3]
                dic6_pro['db_type'] = ','.join(list(set(lst_db)))
                dic6_pro['middleware_type'] = ','.join(list(set(lst_mid)))
                lst6_pro.append(dic6_pro)
            log.info( "zjxx", "=======lst6_pro体检目标信息========================%s"%repr(lst6_pro) )
            # 主机信息分布
            rs_zjfb_count = myapi.sql_execute(cur, sql_zjfb_count)
            while rs_zjfb_count.next():
                rs_zjfb_lst = rs_zjfb_count.to_dict()
                ls_zjfb_count.append(rs_zjfb_lst)
            log.info( "zjxx", "=======ls_zjfb_count主机信息分布========================%s"%repr(ls_zjfb_count) )
            
            cur.execute(sql_zjfb_fst_pro)
            rs_fst_pro = cur.fetchall()
            log.info( "zjxx", "=======rs_fst_pro主机信息分布========================%s"%repr(rs_fst_pro) )
            
            cur.execute(sql_zjfb_sec_pro)
            rs_sec_pro = cur.fetchall()
            log.info( "zjxx", "=======rs_sec_pro主机信息分布========================%s"%repr(rs_sec_pro) )
            
            for l in ls2:
                for ll in rs_fst_pro:
                    if ll[1] == l['agent_id']:
                        ls_fst_pro.append(ll[0])
                dic_fst_pro[l['agent_id']] = ','.join(list(set(ls_fst_pro)))
            log.info( "zjxx", "=======dic_fst_pro主机信息分布========================%s"%repr(dic_fst_pro) )
            for l in ls2:
                for ll in rs_sec_pro:
                    if ll[1] == l['agent_id']:
                        ls_sec_pro.append(ll[0])
                dic_sec_pro[l['agent_id']] = ','.join(list(set(ls_sec_pro)))
            log.info( "zjxx", "=======dic_sec_pro主机信息分布========================%s"%repr(dic_sec_pro) )
            
            #[{'third_pro_count': 11L, 'agent_id': '10000001', 'check_item_count': 43L}, {'third_pro_count': 1L, 'agent_id': '10000002', 'check_item_count': 3L}, {'third_pro_count': 2L, 'agent_id': '10000003', 'check_item_count': 2L}]
            for s in ls_zjfb_count:
                for ss in dic_fst_pro.items():
                    if s['agent_id'] == ss[0]:
                        s['fst_pro'] = ss[1]
            log.info( "zjxx", "=======主机信息分布ls_zjfb_count========================%s"%repr(ls_zjfb_count) )
            for s in ls_zjfb_count:
                for ss in dic_sec_pro.items():
                    if s['agent_id'] == ss[0]:
                        s['sec_pro'] = ss[1]
            log.info( "zjxx", "=======主机信息分布ls_zjfb_count========================%s"%repr(ls_zjfb_count) )
            # 通过项目的总数量
            ls_count_pass, ls_count_unpass, ls_count_uncheck = [], [], []
            rs6 = myapi.sql_execute(cur, sql_6)
            while rs6.next():
                rs_count_pass = rs6.to_dict()
                ls_count_pass.append(rs_count_pass)
            log.info( "zjxx", "=======ls_count_pass通过项目的总数量========================%s"%repr(ls_count_pass) )
            # 未通过项目的总数量
            rs7 = myapi.sql_execute(cur, sql_7)
            while rs7.next():
                rs_count_unpass = rs7.to_dict()
                ls_count_unpass.append(rs_count_unpass)
            log.info( "zjxx", "=======ls_count_unpass未通过项目的总数量========================%s"%repr(ls_count_unpass) )
            # 未核查项目的总数量
            rs8 = myapi.sql_execute(cur, sql_8)
            while rs8.next():
                rs_count_uncheck = rs8.to_dict()
                ls_count_uncheck.append(rs_count_uncheck)
            log.info( "zjxx", "=======ls_count_uncheck未核查项目的总数量========================%s"%repr(ls_count_uncheck) )
            ls_xm_count = ls2
            for i in ls_xm_count:
                for ii in ls_count_pass:
                    if i['agent_id'] == ii['agent_id']:
                        i['pass_count'] = ii.get('pass_count',0)
                for ii in ls_count_unpass:
                    if i['agent_id'] == ii['agent_id']:
                        i['unpass_count'] = ii.get('unpass_count',0)
                for ii in ls_count_uncheck:
                    if i['agent_id'] == ii['agent_id']:
                        i['uncheck_count'] = ii.get('uncheck_count',0)
                i['xm_count'] = str(int(i.get('pass_count',0)) + int(i.get('unpass_count', 0) ) + int(i.get('uncheck_count',0) ))
            log.info( "zjxx", "=======ls_xm_count 项目的数量========================%s"%repr(ls_xm_count) )
            ls_fb_unpass = []
            rs9 = myapi.sql_execute(cur, sql_9)
            while rs9.next():
                rs_fb_unpass = rs9.to_dict()
                ls_fb_unpass.append(rs_fb_unpass)
            log.info( "zjxx", "=======ls_fb_unpass未通过项目的分布========================%s"%repr(ls_fb_unpass) )
            """
            ls_count_unpass 结果集：
            +----------+--------------+
            | agent_id | unpass_count |
            +----------+--------------+
            | 10000001 |        10125 |
            | 10000002 |            3 |
            +----------+--------------+
            ls_fb_unpass 结果集：
            +-------+----------+------------+
            | count | agent_id | second_pro |
            +-------+----------+------------+
            | 10125 | 10000001 | Linux      |
            |     1 | 10000001 | Linux2222  |
            |     2 | 10000002 | MySQL      |
            +-------+----------+------------+
            """
            ls_cpfb = []
            ls_cpfb_unpass = ls_count_unpass
            for i in ls_cpfb_unpass:
                for ii in ls_fb_unpass:
                    if i['agent_id'] == ii['agent_id']:
                        ls_cpfb.append(ii)
                i['ls'] = ls_cpfb
            log.info( "zjxx", "=======ls_cpfb_unpass未通过项目的分布========================%s"%repr(ls_cpfb_unpass) )
            
            # 未通过项目中,三级项目的排名
            ls10 , rs_count_third_lst, ls11 , rs_count_fourth_lst= [], [], [], []
            rs10 = myapi.sql_execute(cur, sql_10)
            while rs10.next():
                rs10_lst = rs10.to_dict()
                ls10.append(rs10_lst)
            for l in ls10:
                l['orderno'] = str(int(l['orderno']))
            log.info( "zjxx", "==================ls10未通过项目中,三级项目的排名==================%s"%repr(ls10) )
            # 未通过项目中,三级项目的总数量
            rs_count_third = myapi.sql_execute(cur, sql_count_third)
            while rs_count_third.next():
                rs_third = rs_count_third.to_dict()
                rs_count_third_lst.append(rs_third)
            log.info( "zjxx", "=======rs_count_third_lst未通过项目中,三级项目的总数量========================%s"%repr(rs_count_third_lst) )
            # 计算各三级项目的比例
            for l in ls10:
                l['counts'] = "%.2f%%"%float( int(l['counts'])/rs_count_third_lst[0]['count'] )
            log.info( "zjxx", "==================ls10计算各三级项目的比例==================%s"%repr(ls10) )
            
            # 未通过项目中,四级项目的排名
            rs11 = myapi.sql_execute(cur, sql_11)
            while rs11.next():
                rs11_lst = rs11.to_dict()
                ls11.append(rs11_lst)
            for l in ls11:
                l['orderno'] = str(int(l['orderno']))
            log.info( "zjxx", "==================ls11未通过项目中,四级项目的排名==================%s"%repr(ls11) )
            # 未通过项目中,四级项目的总数量
            rs_count_fourth = myapi.sql_execute(cur, sql_count_fourth)
            while rs_count_fourth.next():
                rs_fourth = rs_count_fourth.to_dict()
                rs_count_fourth_lst.append(rs_fourth)
            log.info( "zjxx", "=======rs_count_fourth_lst未通过项目中,四级项目的总数量========================%s"%repr(rs_count_fourth_lst) )
            # 计算各四级项目的比例
            for l in ls11:
                l['counts'] = "%.2f%%"%float( int(l['counts'])/rs_count_third_lst[0]['count'] )
            log.info( "zjxx", "==================ls11计算各三级项目的比例==================%s"%repr(ls11) )
            
            ls12, ls13, ls14, ls15 = [], [], [], []
            # 所有的极度危害的未通过的三级项目
            rs12 = myapi.sql_execute(cur, sql_12)
            while rs12.next():
                rs12_lst = rs12.to_dict()
                ls12.append(rs12_lst)
            log.info( "zjxx", "==================ls12所有的极度危害的未通过的三级项目==================%s"%repr(ls12) )
            # 所有的极度危害的通过的三级项目
            rs13 = myapi.sql_execute(cur, sql_13)
            while rs13.next():
                rs13_lst = rs13.to_dict()
                ls13.append(rs13_lst)
            log.info( "zjxx", "==================ls13所有的极度危害的通过的三级项目==================%s"%repr(ls13) )
            # 所有的极度危害的三级项目
            rs14 = myapi.sql_execute(cur, sql_14)
            while rs14.next():
                rs14_lst = rs14.to_dict()
                ls14.append(rs14_lst)
            log.info( "zjxx", "==================ls14所有的极度危害的三级项目==================%s"%repr(ls14) )
            # 所有的极度危害的三级项目的总数量
            rs15 = myapi.sql_execute(cur, sql_15)
            while rs15.next():
                rs15_lst = rs15.to_dict()
                ls15.append(rs15_lst)
            log.info( "zjxx", "==================ls15所有的极度危害的三级项目总数==================%s"%repr(ls15) )
            for i in ls14:
                for ii in ls13:
                    if ii['third_pro'] == i['third_pro']:
                        i['pass_count'] = "%.2f%%"%float( float(ii['pass_count'])/float(ls15[0]['counts']) )
                for iii in ls12:
                    if iii['third_pro'] == i['third_pro']:
                        i['unpass_count'] = "%.2f%%"%float( float(iii['unpass_count'])/float(ls15[0]['counts']) )
            for s in ls14:
                s['orderno'] = str(int(s['orderno']))
                if not s.get('pass_count',''):
                    s['pass_count'] = '0.00%'
                if not s.get('unpass_count',''):
                    s['unpass_count'] = '0.00%'
            log.info( "zjxx", "==================ls14计算极度危害的三级项目的通过与未通过比例==================%s"%repr(ls14) )
            
            ls16, ls17, ls18, tjxx_lst = [], [], [], []
            # 所有的极度危害的未通过的四级项目
            rs16 = myapi.sql_execute(cur, sql_16)
            while rs16.next():
                rs16_lst = rs16.to_dict()
                ls16.append(rs16_lst)
            log.info( "zjxx", "==================ls16所有的极度危害的未通过的四级项目==================%s"%repr(ls16) )
            # 所有的极度危害的通过的四级项目
            rs17 = myapi.sql_execute(cur, sql_17)
            while rs17.next():
                rs17_lst = rs17.to_dict()
                ls17.append(rs17_lst)
            log.info( "zjxx", "==================ls13所有的极度危害的通过的四级项目==================%s"%repr(ls17) )
            # 所有的极度危害的四级项目
            rs18 = myapi.sql_execute(cur, sql_18)
            while rs18.next():
                rs18_lst = rs18.to_dict()
                ls18.append(rs18_lst)
            log.info( "zjxx", "==================ls18所有的极度危害的四级项目==================%s"%repr(ls18) )
            for i in ls18:
                for ii in ls17:
                    if ii['check_item'] == i['check_item']:
                        i['pass_count'] = "%.2f%%"%float( float(ii['pass_count'])/float(ls15[0]['counts']) )
                for iii in ls16:
                    if iii['check_item'] == i['check_item']:
                        i['unpass_count'] = "%.2f%%"%float( float(iii['unpass_count'])/float(ls15[0]['counts']) )
            for s in ls18:
                s['orderno'] = str(int(s['orderno']))
                if not s.get('pass_count',''):
                    s['pass_count'] = '0.00%'
                if not s.get('unpass_count',''):
                    s['unpass_count'] = '0.00%'
            log.info( "zjxx", "==================ls18计算极度危害的四级项目的通过与未通过比例==================%s"%repr(ls18) )
            # 体检信息
            tjxx = myapi.sql_execute(cur, sql_tjxx)
            while tjxx.next():
                tjxx_rs = tjxx.to_dict()
                tjxx_lst.append(tjxx_rs)
            log.info( "zjxx", "==================tjxx_lst体检信息==================%s"%repr(tjxx_lst) )
            for i in tjxx_lst:
                s = i['scheme_time'].split(' ')
                i['name'] = '任务' + i['task_id'] + '主机' + i['agent_id'] + s[0] + '.html'
        return render_to_response( 'check_info.html', {'date_dic':date_dic, 'ls1':ls1[0], 'ls2':ls2[0], 'ls_zjs':ls_zjs, 'ls3':ls3, 'ls4':ls4, 'ls5':ls5, 'rs_count':rs_count, 'ls_zjfb_count':ls_zjfb_count, 'dic6':lst6_pro, 'ls_xm_count':ls_xm_count, 'ls_cpfb_unpass':ls_cpfb_unpass, 'ls_fb_unpass':ls_fb_unpass, 'ls10':ls10, 'ls11':ls11, 'ls14':ls14 , 'ls18':ls18, 'tjxx_lst':tjxx_lst } )
    except Exception, e :
        log.exception( 'zjxx', '后台函数[zjxx_checkinfo_view]执行错误:%s', str( e ) )
        return render_to_response( 'check_info.html', {'xyxx':'后台函数[zjxx_checkinfo_view]执行错误:%s' % str( e )}, context_instance=RequestContext(request) )
        
# 组织数据结构展示体检信息
def zjxx_check_detail_info_view(request):
    try:
        if not request.session.get('username',''):
            return HttpResponseRedirect('/')
        username = request.session.get('username').encode('utf8')
        agent_id = request.GET.get('agent_id').encode('utf8')
        task_id = request.GET.get('task_id').encode('utf8')
        scheme_time = request.GET.get('scheme_time').encode('utf8')
        ip_addr = request.GET.get('ip_addr').encode('utf8')
        mac_addr = request.GET.get('mac_addr').encode('utf8')
        os_fullname = request.GET.get('os_fullname').encode('utf8')
        db_type = request.GET.get('db_type').encode('utf8')
        middleware_type = request.GET.get('middleware_type').encode('utf8')
        log.info( "zjxx", '要查询体检报告的主机是：%s, 任务ID是：%s', agent_id, task_id )
        zjxx = {}
        zjxx['agent_id'] = agent_id
        zjxx['task_id'] = task_id
        zjxx['scheme_time'] = scheme_time
        zjxx['ip_addr'] = ip_addr
        zjxx['mac_addr'] = mac_addr
        zjxx['os_fullname'] = os_fullname
        zjxx['db_type'] = db_type
        zjxx['middleware_type'] = middleware_type
        tjxx_lst = []
        sql_tjxx = "select * from CheckInfo where agent_id='%s' and task_id='%s' order by second_pro desc" % (agent_id, task_id)
        # 体检信息
        with myapi.connection() as con:
            cur = con.cursor()
            tjxx = myapi.sql_execute(cur, sql_tjxx)
            while tjxx.next():
                tjxx_rs = tjxx.to_dict()
                tjxx_lst.append(tjxx_rs)
        return render_to_response( 'check_detail_info.html', {'tjxx_lst':tjxx_lst, 'zjxx':zjxx} )
    except Exception, e :
        log.exception( 'zjxx', '后台函数[zjxx_checkinfo_view]执行错误:%s', str( e ) )
        return render_to_response( 'check_detail_info.html', {'xyxx':'后台函数[zjxx_check_detail_info_view]执行错误:%s' % str( e )}, context_instance=RequestContext(request) )