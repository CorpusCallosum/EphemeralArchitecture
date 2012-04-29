/* Author: Mark Davis
 * 
 * Real documentation for this framework will follow soon.
 * To get a basic idea of what it's about, take a look at cyclopsframework.org.
 * An AS3/Flash version is available under the Apache 2 license.
 * The C# version currently uses Unity's license.
 * 
 */

using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using CyclopsFramework.Core.Easing;
using CyclopsFramework.Actions.Flow;
using CyclopsFramework.Actions.Messaging;

namespace CyclopsFramework.Core
{
    public class CFAction : ICFTaggable, ICFPausable
    {
        public const string TAGS_UNDEFINED = "__undefined__";

        private CFBias.FofT _bias = CFBias.Linear;
        private float _cycle = 0;
        private float _cycles = 1;
		
		private float _period = 0;
        private float _position = 0;
        private float _speed = 1;
        private HashSet<string> _tags = new HashSet<string>();
        private List<CFAction> _children = new List<CFAction>();
        
		public float Period { get { return _period; } }
		
        public float Cycle { get { return _cycle; } }
        public float Cycles { get { return _cycles; } }
        
        public float Position
        {
            get { return ((_position - _cycle) >= 1) ? 1 : (_position - _cycle); }
        }
        
		public float Speed
        {
            get { return _speed; }
            set { _speed = value; }
        }

        private Queue _dataPipe = new Queue();
        public Queue DataPipe { get { return _dataPipe; } }
		
        public HashSet<string> Tags { get { return _tags; } }
        
		private bool _paused = false;
        public bool Paused { get { return _paused; } set { _paused = value; } }
		
        public List<CFAction> Children { get { return _children; } }
		
		private bool _active = true;
		public bool IsActive { get { return _active; } }
		
		public event EventHandler Entering;
		public event EventHandler Entered;
		public event EventHandler Exited;
		public event EventHandler Exiting;
		
        private CFEngine _engine;
        public CFEngine Engine
        {
            get { return _engine; }
            set { _engine = value; }
        }

		public CFAction(Action<CFAction> constructor)
		{	
			constructor(this);
            if (_tags.Count == 0) AddTag(CFAction.TAGS_UNDEFINED);
		}
		
        public CFAction(List<string> tags)
        {
            if (tags == null) AddTag(CFAction.TAGS_UNDEFINED);
            else AddTags(tags);
        }

        public CFAction(float period, float cycles, CFBias.FofT bias, string tag)
        {
            _cycles = cycles;
            _period = period;
            _bias = (bias == null) ? CFBias.Linear : bias;
            if (tag == null) AddTag(CFAction.TAGS_UNDEFINED);
            else AddTag(tag);
        }

        public HashSet<string> GetTags()
        {
            return _tags;
        }

        public bool GetPaused()
        {
            return _paused;
        }

        public void SetPaused(bool value)
        {
            _paused = value;
        }
		
		public CFAction Add(params object[] taggedObjects)
		{
			var currTags = new List<String>();
			CFAction currAction = null;
			
			foreach (var o in taggedObjects)
			{
				if (o is CFAction)
				{
					currAction = (CFAction)o;
					if (currTags.Count > 0)
					{
						currAction.AddTags(currTags);
						currTags.Clear();
					}
					_children.Add((CFAction)o);
				}
				else if (o is IEnumerable)
				{
					String[] contextualTags = new String[currTags.Count];
					currTags.CopyTo(contextualTags);
					currTags.Clear();
					foreach (var ao in (IEnumerable)o)
					{
						if (ao is String)
						{
							currTags.Add((String)ao);
						}
						else if (ao is IEnumerable)
						{
							Add(currTags, contextualTags, (IEnumerable)ao);
						}
						else
						{
							Add(currTags, contextualTags, ao);
							currTags.Clear();
						}
					}
				}
				else if (o is String)
				{
					currTags.Add((String)o);
				}
			}
			
			return currAction;
			
		}
		
		public CFAction Add(CFFunction.F f)
		{
			var action = (CFAction)(new CFFunction(f));
			_children.Add(action);
			return action;
		}
		
		public CFAction Add(object data, CFFunction.Fd f)
		{
			var action = (CFAction)(new CFFunction(data, f));
			_children.Add(action);
			return action;
		}
		
        private CFAction AddSequence(IEnumerable items, bool returnHead)
        {
			CFAction head = null;
            CFAction tail = null;
			CFAction currAction = null;
			
            foreach (var o in items)
            {
				currAction = Add(o);
				if (currAction != null)
				{
	                if (head == null)
	                {
	                    head = tail = currAction;
	                }
	                else if (head != null)
	                {
	                    tail = tail.Add(o);
	                }
				}
            }

            return (returnHead ? head : tail);
        }
		
		public CFAction AddSequenceReturnHead(IEnumerable items)
		{
			return AddSequence(items, true);
		}
		
		public CFAction AddSequenceReturnTail(IEnumerable items)
		{
			return AddSequence(items, false);
		}
		
        #region SyntacticSugar

        // in C# 3.0+, these functions would be better off in an extentions class, rather than cluttering up this code and
        // permentantly linking the parent to derived classes... ugh... just about as bad as linking the engine to the actions.
        // but it does make life easier and given the scope of the framework, i don't think it's a real problem.

        public CFAction Log(object message)
        {
            return this.Add(delegate() { System.Diagnostics.Debug.WriteLine(message); });
        }

        public CFAction Send(string receiverTag, string name, params object[] data)
        {
            return this.Add(delegate()
            {
                if (Engine != null) Engine.Send(new object(), null, receiverTag, name, data);
            });
        }

        public CFAction Send(object sender, Type receiverType, string receiverTag, string name, params object[] data)
        {
            return this.Add(delegate()
            {
                if (Engine != null) Engine.Send(receiverTag, name, data, sender, receiverType);
            });
        }

        public CFAction Sleep(float period)
        {
            return this.Add(new CFSleep(period));
        }

        public CFAction WaitForMessage(string receiverTag, string messageName)
        {
            return this.Add(new CFWaitForMessage(messageName), receiverTag);
        }

        public CFAction WaitForMessage(string receiverTag, string messageName, float timeout, float cycles)
        {
            return this.Add(new CFWaitForMessage(messageName, timeout, cycles), receiverTag);
        }

        public CFAction WaitForMessage(string receiverTag, string messageName, float timeout, float cycles, CFWaitForMessage.Fd f)
        {
            return this.Add(new CFWaitForMessage(messageName, timeout, cycles, f), receiverTag);
        }

        public CFAction WaitForMessage(string receiverTag, string messageName, float timeout, float cycles, CFWaitForMessage.Fd f, CFWaitForMessage.FTimeOut timeoutListener)
        {
            return this.Add(new CFWaitForMessage(messageName, timeout, cycles, f, timeoutListener), receiverTag);
        }

        public CFAction WaitUntil(CFWaitUntil.F condition)
        {
            return this.Add(new CFWaitUntil(condition));
        }

        public CFAction WaitUntil(CFWaitUntil.F condition, float timeout)
        {
            return this.Add(new CFWaitUntil(condition, timeout));
        }

        #endregion

        public ICFTaggable AddTag(string tag)
		{
			if(!Tags.Contains(tag)) Tags.Add(tag);
			return this;
		}

        public ICFTaggable AddTags(IEnumerable<string> tags)
		{
			foreach (string tag in tags)
			{
				AddTag(tag);
			}
			return this;
		}

        public void Clear()
        {
            _children.Clear();
        }

        public CFAction Remove(CFAction child)
        {
            _children.Remove(child);
            return child;
        }

        public void Stop()
        {
            Stop(true, true);
        }

        public void Stop(bool callLastFrame, bool callExit)
        {
            if (_active)
            {
				//System.Diagnostics.Debug.WriteLine("Stop!");
				_active = false;
                if (callLastFrame)
				{
					OnLastFrame();
				}
                if (callExit)
				{
					if (Exiting != null) Exiting(this, EventArgs.Empty);
					OnExit();
					if (Exited != null) Exited(this, EventArgs.Empty);
				}
            }
			else
			{
				//System.Diagnostics.Debug.WriteLine("Already Stopped!");
			}
			
			_active = false;
        }

        public bool Update(float delta)
        {
            if (!_active) return false;

            if (_position == 0)
            {
                if(_cycle == 0)
                {
					if (Entering != null) Entering(this, EventArgs.Empty);
                    OnEnter();
					if (Entered != null) Entered(this, EventArgs.Empty);
                }
                OnFirstFrame();
            }

            if (_cycle >= _cycles)
            {
                Stop();
                return _active;
            }

            OnFrame(_bias(Position));
            
			if(_period > 0)
			{
            		_position += (delta * _speed) / _period;
			}
			else
			{
				++_position;
			}
			
            if ((_position - _cycle) >= 1)
            {
                if (_cycle < (_cycles - 1))
                {
                    OnLastFrame();
                    ++_cycle;
					
					if (_cycle >= _cycles)
		            {
		                Stop(false, true);
		                return _active;
		            }
					
                    OnFirstFrame();
                }
                else
                {
                    Stop();
                }
            }
			
            return _active;
        }
		
        protected virtual void OnEnter() { }
        protected virtual void OnFirstFrame() { }
        protected virtual void OnFrame(float t) { }
        protected virtual void OnLastFrame() { }
        protected virtual void OnExit() { }
    }
}
