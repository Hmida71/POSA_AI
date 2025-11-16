A3='healthy'
A2='WARNING'
A1='running'
A0='Task completed'
z='Task completed successfully'
y='gemini'
t='POSA Backend'
s='service'
r='extracted_content'
q='llm'
p='agent_log'
o='module'
n='level'
m=reversed
l=UnicodeEncodeError
k='error'
j='api_key'
i='model_version'
h='agent'
g='%H:%M:%S'
f='message'
e='replace'
c='server'
b='model'
a='agent_status'
Z=None
Y=''
X='utf-8'
W=isinstance
T="'"
S='ERROR'
R='timestamp'
O=False
N=hasattr
K='status'
J=Exception
H='browser'
G='INFO'
F=True
E=print
D=str
from flask import Flask,render_template,request,jsonify as d,send_from_directory
from flask_socketio import SocketIO as A4,emit as u
import asyncio as L,os as P,sys as U,json,threading as v
from datetime import datetime as Q
import logging as M,re as B,atexit,asyncio as L,io
if U.platform.startswith('win'):
	U.stdout=io.TextIOWrapper(U.stdout.buffer,encoding=X,errors=e);U.stderr=io.TextIOWrapper(U.stderr.buffer,encoding=X,errors=e)
	try:import locale as w;w.setlocale(w.LC_ALL,'en_US.UTF-8')
	except:pass
	P.environ['PYTHONIOENCODING']=X
U.path.append(P.path.dirname(P.path.dirname(P.path.abspath(__file__))))
from dotenv import load_dotenv
from langchain_google_genai import ChatGoogleGenerativeAI as A5
from langchain_openai import ChatOpenAI as x
from langchain_anthropic import ChatAnthropic as A6
from browser_use import Agent,BrowserSession as A7,BrowserProfile as A8
V=Flask(__name__)
V.config['SECRET_KEY']='your-secret-key-here'
C=A4(V,cors_allowed_origins='*',async_mode='threading')
class A9(M.Handler):
	def __init__(A,socketio):super().__init__();A.socketio=socketio
	def emit(A,record):
		B=record
		try:C=A.format(B)
		except l:C=D(B.getMessage()).encode(X,errors=e).decode(X)
		if A.should_skip_message(C):return
		E=A.clean_message(C);F={R:Q.now().strftime(g),n:B.levelname,f:E,o:B.name};A.socketio.emit(p,F)
	def should_skip_message(D,message):
		A=['🛠️\\s*Action \\d+/\\d+:','Action \\d+/\\d+:.*\\{.*\\}','\\{"done":\\{"text":','\\{"search_google":','\\{"click":','\\{"type":','\\{"navigate":','\\{"scroll":','\\{"extract":']
		for C in A:
			if B.search(C,message,B.IGNORECASE):return F
		return O
	def clean_message(F,message):
		C=[('^\\[agent\\]\\s*',Y),('^\\[controller\\]\\s*',Y),('^\\[browser_use\\]\\s*',Y)];A=message
		for(D,E)in C:A=B.sub(D,E,A)
		return A.strip()
def AA():B=M.getLogger('browser_use');B.setLevel(M.INFO);D=M.getLogger(h);D.setLevel(M.INFO);E=M.getLogger('controller');E.setLevel(M.INFO);A=A9(C);F=M.Formatter('%(message)s');A.setFormatter(F);B.addHandler(A);D.addHandler(A);E.addHandler(A)
def A(level,message,module=h):
	F='ascii';E=module;B=level;A=message
	try:
		if W(A,bytes):A=A.decode(X,errors=e)
		elif not W(A,D):A=D(A)
		C.emit(p,{R:Q.now().strftime(g),n:B,f:A,o:E})
	except J as H:G=A.encode(F,errors='ignore').decode(F);C.emit(p,{R:Q.now().strftime(g),n:B,f:f"{G} [encoding issue resolved]",o:E})
def AB(model_type,model_version,api_key):
	F=.0;E=model_version;C=model_type;B=api_key
	try:
		if C==y:P.environ['GOOGLE_API_KEY']=B;return A5(model=E,temperature=F,google_api_key=B)
		elif C=='gpt':P.environ['OPENAI_API_KEY']=B;return x(model=E,temperature=F,openai_api_key=B)
		elif C=='claude':P.environ['ANTHROPIC_API_KEY']=B;return A6(model=E,temperature=F,anthropic_api_key=B)
		elif C=='deepseek':return x(model=E,temperature=F,openai_api_key=B,base_url='https://api.deepseek.com/v1')
		else:raise ValueError(f"Unsupported model type: {C}")
	except J as G:A(S,f"Failed to initialize {C.upper()} model: {D(G)}",q);raise
def AC(raw_result):
	Y='🔍 Searched for';X='text';V='done';Q='"';P='\\"';O="\\'";A=raw_result
	try:
		if N(A,'all_model_outputs')and N(A,'all_results'):
			for I in m(A.all_model_outputs):
				if W(I,dict)and V in I:
					K=I[V]
					if W(K,dict)and X in K:return K[X].strip()
			for C in m(A.all_results):
				if N(C,'is_done')and C.is_done and N(C,r):
					L=C.extracted_content
					if L and not L.startswith(Y):return L.strip()
		if W(A,D):return A.strip()
		if W(A,list)and A:
			M=A[-1]
			if N(M,r):return D(M.extracted_content).strip()
			return D(M).strip()
		H=D(A);Z=["'done':\\s*\\{\\s*'text':\\s*'([^']*(?:\\\\'[^']*)*)'",'"done":\\s*\\{\\s*"text":\\s*"([^"]*(?:\\\\"[^"]*)*)"','\'done\':\\s*\\{\\s*\'text\':\\s*\\"([^\\"]+)\\"','"done":\\s*\\{\\s*"text":\\s*\\\'([^\\\']+)\\\'',"'done':\\s*\\{\\s*'text':\\s*'([^']+(?:'[^'}]*)*)",'"done":\\s*\\{\\s*"text":\\s*"([^"]+(?:"[^"}]*)*)','\'text\':\\s*[\'\\"]([^\'\\"]*(?:[\'\\"][^\'\\"]*)*)[\'\\"](?:\\s*,\\s*\'success\'|$)']
		for G in Z:
			F=B.findall(G,H,B.IGNORECASE|B.DOTALL)
			if F:
				C=F[-1];C=C.replace(O,T).replace(P,Q).strip()
				if C and len(C)>10:return C
		R=B.search("'done':\\s*\\{([^}]+)\\}",H,B.DOTALL)
		if R:
			a=R.group(1);S=B.search('\'text\':\\s*[\'\\"]([^\'\\"]+)[\'\\"]',a,B.DOTALL)
			if S:return S.group(1).replace(O,T).replace(P,Q).strip()
		b=['is_done=True[^,]*extracted_content=[\'\\"]([^\'\\"]+)[\'\\"]','extracted_content=[\'\\"]([^\'\\"]*(?:\\$|worth|billion|million)[^\'\\"]*)[\'\\"]']
		for G in b:
			F=B.findall(G,H,B.IGNORECASE|B.DOTALL)
			if F:
				for U in m(F):
					if not U.startswith(Y):return U.replace(O,T).replace(P,Q).strip()
		c=['net worth[^.]*\\$[0-9.,]+[^.]*billion[^.]*\\.','worth[^.]*\\$[0-9.,]+[^.]*billion[^.]*\\.','estimated[^.]*\\$[0-9.,]+[^.]*billion[^.]*\\.']
		for G in c:
			F=B.findall(G,H,B.IGNORECASE|B.DOTALL)
			if F:return F[-1].strip()
		return z
	except J as d:E(f"Error extracting result: {d}");return A0
class AD:
	def __init__(A):A.agent=Z;A.is_running=O;A.browser_session=Z
	async def run_task(B,task,model_config,keep_browser_open=F):
		U=keep_browser_open;P='result';L=model_config
		try:
			B.is_running=F;C.emit(a,{K:A1,'task':task});A(G,f"🧠 Initializing {L[b].upper()} {L[i]}",q);Y=AB(L[b],L[i],L[j]);A(G,f"✅ {L[b].upper()} model loaded successfully",q);Z=A8(window_size={'width':1400,'height':800});B.browser_session=A7(keep_alive=U,browser_profile=Z);B.agent=Agent(task=task,llm=Y,browser_session=B.browser_session);A(G,f"🌐 Browser session initialized (keep_alive: {U})",H);V=await B.agent.run()
			try:E(f"Raw result type: {type(V)}");E(f"Raw result: {V}")
			except l:E('Raw result contains unicode characters - logged safely')
			I=AC(V)
			if I==z or I==A0:
				try:
					if N(B.agent,'history')and B.agent.history:
						M=B.agent.history[-1]
						if N(M,r)and M.extracted_content:I=M.extracted_content.replace(T,T).strip()
						elif N(M,P)and M.result:I=D(M.result).replace(T,T).strip()
				except J as W:E(f"Error getting result from history: {W}")
			A(G,f"📊 Final result: {I}",h);C.emit('final_result',{R:Q.now().strftime(g),P:I,'formatted_result':f"📄 Result: {I}"})
			if not U:await B.close_browser();A(G,'🔒 Browser closed automatically (keep_browser_open: False)',H)
			C.emit(a,{K:'completed',P:I});C.emit('task_completed',{P:I})
		except J as W:X=f"Error: {D(W)}";C.emit(a,{K:k,k:X});A(S,X,h)
		finally:B.is_running=O
	async def close_browser(I):
		R='cmdline';N='name'
		try:
			K=O;A(G,'🔄 Attempting to close browser...',H)
			try:
				import psutil as C;L=0;A(G,'🔧 Attempting force close of browser processes...',H)
				for B in C.process_iter(['pid',N,R]):
					try:
						M=B.info
						if not M[N]:continue
						P=M[N].lower()
						if any(A in P for A in['chrome','chromium','msedge','firefox']):
							Q=M.get(R,[])
							if Q:
								T=' '.join(Q)
								if any(A in T for A in['--remote-debugging-port','browseruse','--user-data-dir','--disable-blink-features=AutomationControlled']):
									A(G,f"🎯 Found browser process: {P} (PID: {B.pid})",H);B.terminate()
									try:B.wait(timeout=5)
									except C.TimeoutExpired:B.kill();B.wait()
									L+=1
					except(C.NoSuchProcess,C.AccessDenied,C.TimeoutExpired):continue
					except J as E:continue
				if L>0:K=F;A(G,f"✅ Force closed {L} browser process(es)",H)
				else:A(A2,'⚠️ No browser processes found to close',H)
			except ImportError:A(S,'❌ psutil not available. Install with: pip install psutil',H)
			except J as E:A(S,f"❌ Force close failed: {D(E)}",H)
			if K:
				I.browser_session=Z
				if I.agent:I.agent.browser_session=Z
			return K
		except J as E:A(S,f"❌ Error in close_browser: {D(E)}",H);return O
I=AD()
@V.route('/')
def AE():return d({s:t,K:A1,f:'Browser Use Agent Web UI Backend is running','port':5000,'socketio_available':F})
@V.route('/status')
def AF():return d({K:A3,'agent_running':I.is_running if I else O,R:Q.now().isoformat(),s:t})
@V.route('/health')
def AG():
	try:return d({K:A3,s:t,'port':5000,R:Q.now().isoformat(),'agent_available':I is not Z,'socketio_running':F}),200
	except J as A:return d({K:k,k:D(A),R:Q.now().isoformat()}),500
@C.on('connect')
def AH():E('Client connected');u(a,{K:'ready'})
@C.on('disconnect')
def AI():E('Client disconnected')
@C.on('start_task')
def AJ(data):
	B=data;C=B.get('task',Y);D=B.get('keep_browser_open',F);E={b:B.get(b,y),i:B.get(i,'gemini-2.0-flash'),j:B.get(j,Y)}
	if not C:A(S,'No task provided',c);return
	if not E[j]:A(S,'API key is required',c);return
	if I.is_running:A(A2,'Agent is already running a task',c);return
	A(G,f"🔧 Keep browser open after task: {D}",c)
	def J():A=L.new_event_loop();L.set_event_loop(A);A.run_until_complete(I.run_task(C,E,D));A.close()
	H=v.Thread(target=J);H.daemon=F;H.start()
@C.on('stop_task')
def AK():
	if I.agent and I.is_running:I.is_running=O;u(a,{K:'stopped'});A(G,'Task stopped by user',c)
@atexit.register
def AL():
	try:
		A=L.get_event_loop()
		if not A.is_closed():
			B=L.all_tasks(A)
			for C in B:C.cancel()
			if B:A.run_until_complete(L.gather(*B,return_exceptions=F))
	except:pass
@C.on('close_browser')
def AM():
	def B():A=L.new_event_loop();L.set_event_loop(A);A.run_until_complete(I.close_browser());A.close()
	A=v.Thread(target=B);A.daemon=F;A.start()
if __name__=='__main__':
	AA()
	try:E('Starting Browser Use Agent Web UI... 🚀');E('Open http://localhost:5000 in your browser 🌐')
	except l:E('Starting Browser Use Agent Web UI...');E('Open http://localhost:5000 in your browser')
	C.run(V,debug=O,host='0.0.0.0',port=5000,allow_unsafe_werkzeug=F)