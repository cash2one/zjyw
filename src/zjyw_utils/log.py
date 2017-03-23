# -*- coding: utf8 -*-
import logging , sys , traceback2
import loghandler
from django.conf import settings

import os

def init_log( name = None , screen = False , thread = True ):
    #settings.check( 'LOGDIR' , 'LOGLEVEL' )
    return init_logger( name , settings.LOGDIR , screen , thread )

init = init_log

def init_logger( logname , logdir , screen = True , thread = True ):
    logobj = logging.getLogger( logname )
    # 判断是否需要清理
    if logobj.handlers:
        return  logobj  # 日志已创建，跳过
#        # 有处理句柄，则该日志对象需要清理
        logobj.info( '日志[%s]重新初始化' , logname )
        for hdl in logobj.handlers[:]:
            logobj.removeHandler( hdl )
    
    # 初始化日志文件处理句柄
    fn = '%s.log' % logname
    hdlr = loghandler.DateFileHandler( os.path.join( logdir , fn ) )
    fmts = '%(asctime)s ' + ( 'T%(thread)d ' if thread else '' ) +  '%(levelname)s %(message)s'
    formatter = logging.Formatter( fmts )
    hdlr.setFormatter(formatter)
    logobj.addHandler( hdlr )
    
    if screen:
        # 初始化屏幕打印处理句柄
        hdlr = logging.StreamHandler()
        fmts = '%(asctime)s %(name)s：' + ( 'T%(thread)d ' if thread else '' ) + '%(levelname)s %(message)s'
        formatter = logging.Formatter( fmts )
        hdlr.setFormatter(formatter)
        logobj.addHandler( hdlr )

    logobj.setLevel( settings.LOGLEVEL )
    return logobj

def _fmt_msg( *args , **kwargs ):
    if len( args ) > 1:
        msg = args[0] % args[1:]
    elif len( args ) == 1:
        msg = args[0]
    else:
        msg = ''
    
    block = kwargs.get( 'block' )
    if type(block) is str:
        # 是块日志
        bin = kwargs.get( 'bin' , True )
        if bin:
            block = to_hex( block )
    
    if block:
        block = '\n'+'='*40+'\n'+block+ ('\n' if block[-1] != '\n' else '' ) +'='*40 + '\n'
    elif msg[-1] == '\n':
        block = ''
    else:
        block = '\n'
    
    msg = msg + block
    if msg[-1] == '\n':
        msg = msg[:-1]
    return msg
    
def debug( logname , *args , **kwargs ):
    if logname:
        logger = init_log( logname )
        logger.debug( _fmt_msg( *args , **kwargs ) )

def info( logname , *args , **kwargs ):
    if logname:
        logger = init_log( logname )
        logger.info( _fmt_msg( *args , **kwargs ) )
        
def warning( logname , *args , **kwargs ):
    if logname:
        logger = init_log( logname )
        logger.warning( _fmt_msg( *args , **kwargs ) )
        
def error( logname , *args , **kwargs ):
    if logname:
        logger = init_log( logname )
        logger.error( _fmt_msg( *args , **kwargs ) )
        
def critical( logname , *args , **kwargs ):
    if logname:
        logger = init_log( logname )
        logger.critical( _fmt_msg( *args , **kwargs ) )

def exception( logname , *args , **kwargs ):
    if logname:
        logger = init_log( logname )
        exc_msg = traceback2.format_exc( show_locals = True )
        args = list( args )
        if args:
            args[0] += '\n%s'
        else:
            args.append( '%s' )
        args.append( exc_msg )
        logger.error( _fmt_msg( *args , **kwargs ) )
        return ''

if __name__ == "__main__":
    init_log( 'zjxx' , True )
    init_log( 'zjxx' , True )