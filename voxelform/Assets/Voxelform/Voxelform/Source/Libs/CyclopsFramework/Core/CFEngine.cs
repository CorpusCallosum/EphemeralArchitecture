/* Author: Mark Davis
 * 
 * The engine is the core of the Cyclops Framework.
 * Real documentation for this framework will follow soon.
 * To get a basic idea of what it's about, take a look at cyclopsframework.org.
 * An AS3/Flash version is available under the Apache 2 license.
 * The C# version currently uses Unity's license.
 * 
 */
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using CyclopsFramework.Actions.Flow;
using CyclopsFramework.Actions.Messaging;
using CyclopsFramework.Core;

namespace CyclopsFramework.Core
{
    public class CFEngine
    {
        struct CFStopActionRequest
        {
            public string actionTag;
            public bool stopChildren;

            public CFStopActionRequest(string actionTag, bool stopChildren)
            {
                this.actionTag = actionTag;
                this.stopChildren = stopChildren;
            }
        }

        public static string TAG_ALL = "*";

        public delegate bool TaggableFilterFunction(ICFTaggable o);
		
        private Dictionary<string, HashSet<ICFTaggable>> _registry;

        private Queue<CFAction> _actions;
        private Queue<ICFTaggable> _additions;
        private Queue<ICFTaggable> _removals;
        private Queue<CFEngine.CFStopActionRequest> _stopsRequested;
		private Queue<CFMessage> _messages;
        private HashSet<string> _pausesRequested;
        private HashSet<string> _resumesRequested;
		private HashSet<string> _blocksRequested;
		private HashSet<string> _autotags;
		
		public delegate void DelayedFunction();
		private List<DelayedFunction> _delayedFunctions;
		
		private CFAction _context;
		public CFAction Context { get { return _context; } }

        private float _delta = 1f / 60f;
        public float Delta { get { return _delta; } }
        public float Fps { get { return 1f / _delta; } }
		
        public CFEngine()
        {
            _registry = new Dictionary<string, HashSet<ICFTaggable>>();

            _actions = new Queue<CFAction>();
            _additions = new Queue<ICFTaggable>();
            _removals = new Queue<ICFTaggable>();
            _stopsRequested = new Queue<CFEngine.CFStopActionRequest>();
            _messages = new Queue<CFMessage>();
            _pausesRequested = new HashSet<string>();
            _resumesRequested = new HashSet<string>();
            _blocksRequested = new HashSet<string>();
            _autotags = new HashSet<string>();
			_delayedFunctions = new List<DelayedFunction>();
			
			BeginTag(TAG_ALL);
			
        }
		
		#region Sequencing Tags
		
		public void BeginTag(string tag)
		{
            _autotags.Add(tag);
		}
		
		public void EndTag(string tag)
		{
            _autotags.Remove(tag);
		}
		
		private void ApplyAutotags(ICFTaggable o)
		{
			foreach (string tag in _autotags)
			{
                o.Tags.Add(tag);
			}
		}
		
		#endregion
		
		#region Sequencing Additions
		
		public CFAction Add(params object[] taggedObjects)
		{
			var currTags = new List<String>();
			CFAction currAction = null;
			
			foreach (var o in taggedObjects)
			{
				if (o is CFAction)
				{
					currAction = (CFAction)o;
					ApplyAutotags(currAction);
					if (currTags.Count > 0)
					{
						currAction.AddTags(currTags);
						currTags.Clear();
					}
					_additions.Enqueue((CFAction)o);
				}
				else if (o is ICFTaggable)
				{
					var taggedObject = (ICFTaggable)o;
					ApplyAutotags(taggedObject);
					if (currTags.Count > 0)
					{
						foreach (var tag in currTags)
						{
							taggedObject.Tags.Add(tag);
						}
						currTags.Clear();
					}
					_additions.Enqueue(taggedObject);
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
			return Add(new CFFunction(f));
		}
		
		public CFAction Add(object data, CFFunction.Fd f)
		{
			return Add(new CFFunction(data, f));
		}
		
        private CFAction AddSequence(IEnumerable items, bool returnHead)
        {
			CFAction head = null;
            CFAction tail = null;
			CFAction currAction = null;
			
            foreach (var o in items)
            {
				if (currAction == null)
				{
					currAction = Add(o);
					head = tail = currAction;
				}
				else
                {
                    tail = tail.Add(o);
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
		
		public void runNextFrame(DelayedFunction f)
		{
			_delayedFunctions.Add(f);
		}
		
		#endregion
		
		#region Control Flow

        public void Pause(string tag)
		{
			_pausesRequested.Add(tag);
        }

		public void Pause(IEnumerable<string> tags)
        {
            foreach (string tag in tags)
            {
                Pause(tag);
            }
        }

        public void Resume(string tag)
        {
			_resumesRequested.Add(tag);    
        }

        public void Resume(IEnumerable<string> tags)
        {
            foreach (string tag in tags)
            {
				Resume(tag);
            }
        }
		
		public void Block(string tag)
		{
			_blocksRequested.Add(tag);
		}
		
		public void Block(IEnumerable<string> tags)
        {
            foreach (string tag in tags)
            {
                Block(tag);
            }
        }

        public void Remove(string tag, bool stopChildren)
        {
			_stopsRequested.Enqueue(new CFStopActionRequest(tag, stopChildren));
        }

        public void Remove(IEnumerable<string> tags, bool stopChildren)
        {
            foreach (string tag in tags)
            {
                Remove(tag, stopChildren);
            }
        }

        public void Remove(ICFTaggable taggedObject)
        {
            if (taggedObject is CFAction)
            {
                ((CFAction)taggedObject).Stop();
            }
            else
            {
                _removals.Enqueue(taggedObject);
            }
        }

		#endregion
		
		#region Registration & Housekeeping

        private void Register(ICFTaggable taggedObject)
        {
            foreach (string tag in taggedObject.Tags)
            {
                if (_registry.ContainsKey(tag))
                {
                    _registry[tag].Add(taggedObject);
                }
                else
                {
                    _registry.Add(tag, new HashSet<ICFTaggable>());
                    _registry[tag].Add(taggedObject);
                }
            }
        }

        private void Unregister(ICFTaggable taggedObject)
        {
            foreach (string tag in taggedObject.Tags)
            {
				if(taggedObject is ICFDisposable)
				{
					((ICFDisposable)taggedObject).Dispose();
				}
				
                _registry[tag].Remove(taggedObject);
            }
        }
		
		public void AddObject(ICFTaggable taggedObject)
		{
			ApplyAutotags(taggedObject);
			_additions.Enqueue(taggedObject);
		}

		#endregion
		
		#region Querying
		
		public int Count(string tag)
        {
            if (_registry.ContainsKey(tag))
            {
                return _registry[tag].Count;
            }
            return 0;
        }
		
		public bool TimerReady(string tag, float period)
		{
			if (Count(tag) == 1) return false;
			Sleep(period).AddTag(tag);
			return true;
		}
        
        public List<ICFTaggable> Filter(params string[] tags)
        {
            var results = new List<ICFTaggable>();

            foreach (var tag in tags)
            {
                if (_registry.ContainsKey(tag))
                {
                    results.AddRange(_registry[tag]);
                }
            }

            return results;
        }

        public List<ICFTaggable> Filter(IEnumerable<string> tags)
        {
            var results = new List<ICFTaggable>();

            foreach (var tag in tags)
            {
                if (_registry.ContainsKey(tag))
                {
                    results.AddRange(_registry[tag]);
                }
            }

            return results;
        }

        public List<ICFTaggable> Filter(IEnumerable<string> tags, TaggableFilterFunction f)
        {
            var results = new List<ICFTaggable>();

            foreach (var tag in tags)
            {
                if (_registry.ContainsKey(tag))
                {
                    foreach (var o in _registry[tag])
                    {
                        if (f(o)) results.Add(o);
                    }
                }
            }

            return results;
        }

        /* not supported in 3.5, was intended for 4.0
        public dynamic Proxy(string tag)
        {
            return new CFProxy(this, tag);
        }
        */
        
		#endregion

        #region SyntacticSugar

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

        #region Messaging
		
		public void Send(string receiverTag, string name, params object[] data)
		{
			Send(new object(), null, receiverTag, name, data);
		}
		
		public void Send(object sender, Type receiverType, string receiverTag, string name, params object[] data)
		{
			_messages.Enqueue(new CFMessage(receiverTag, name, data, sender, receiverType));
		}
        
        public void DeliverMessage(CFMessage msg)
		{
            if (_registry.ContainsKey(msg.ReceiverTag))
            {
                foreach (ICFTaggable o in _registry[msg.ReceiverTag])
                {
                    DeliverMessage(msg, o);
                }
            }
        }
		
		private void DeliverMessage(CFMessage msg, object receiver)
		{
			if(msg.ReceiverType != null)
			{
				if(!(receiver.GetType().Equals(msg.ReceiverType)))
				{
					return;
				}
			}

            if (receiver is ICFMessageInterceptor)
            {
                (receiver as ICFMessageInterceptor).InterceptMessage(msg);
            }

            if (msg.IsCanceled)
            {
                return;
            }
			
            MethodInfo minfo;

            if (msg.Data.Length > 0)
            {
                Type[] types = new Type[msg.Data.Length];
            
                for (int i = 0; i < msg.Data.Length; ++i)
                {
                    types[i] = (Type)(msg.Data[i]);
                }

                minfo = receiver.GetType().GetMethod(msg.Name, types);
            }
            else
            {
                minfo = receiver.GetType().GetMethod(msg.Name, new Type[] {});
            }

			if(minfo != null)
			{
                if ((msg.Sender != null) && (msg.Sender is ICFResult))
                {
                    ((ICFResult)msg.Sender).Result = minfo.Invoke(receiver, msg.Data);
                }
                else
                {
                    minfo.Invoke(receiver, msg.Data);
                }
			}
			else
			{
				PropertyInfo pinfo = receiver.GetType().GetProperty(msg.Name);
				if(pinfo != null)
				{
					if(msg.Data.Length == 1)
					{
						pinfo.SetValue(receiver, msg.Data[0], null);
					}
					else if(msg.Data.Length > 1)
					{
						msg.Name = msg.Data[0] as string;
                        object[] tmpArray = new object[msg.Data.Length - 1];
                        Array.Copy(msg.Data, 1, tmpArray, 0, msg.Data.Length - 1);
                        msg.Data = tmpArray;
						DeliverMessage(msg, pinfo.GetValue(receiver, null));
					}
				}
			}
		}
		
		#endregion
		
		#region Updates
		
		public void ProcessDelayedFunctions()
		{
			foreach (DelayedFunction f in _delayedFunctions)
			{
				f();
			}
			_delayedFunctions.Clear();
		}
		
		private void ProcessActions(float delta)
		{
			int actionCount = _actions.Count;
			
            for (int i = 0; i < actionCount; ++i)
            {
                CFAction action = (CFAction)_actions.Dequeue();
				_actions.Enqueue(action);
				_context = action;
				action.Update(delta);
            }
			_context = null;
		}
		
		private void ProcessMessages()
		{
			while (_messages.Count > 0)
			{
				CFMessage msg = (CFMessage)_messages.Dequeue();
				
				if(_registry.ContainsKey(msg.ReceiverTag))
				{
					foreach (ICFTaggable o in _registry[msg.ReceiverTag])
					{
						DeliverMessage(msg, o);
					}
				}
			}
		}
		
		private void ProcessStopRequests()
		{
			while (_stopsRequested.Count > 0)
            {
                CFStopActionRequest request = (CFStopActionRequest)_stopsRequested.Dequeue();
                if (_registry.ContainsKey(request.actionTag))
                {
                    foreach (CFAction action in _registry[request.actionTag])
                    {
						if(action is CFAction)
						{
							((CFAction)action).Stop();
						}
					}
                }
            }
		}
		
		private void ProcessRemovals()
		{
            // CFActions are excluded from the _removals list.
            foreach (var taggedObject in _removals)
            {
                Unregister(taggedObject);
            }

            // process CFActions here.

			int actionCount = _actions.Count;
			
            for (int i = 0; i < actionCount; ++i)
            {
                CFAction action = (CFAction)_actions.Dequeue();
				
				if(!(action.IsActive))
				{
					Unregister(action);

                    string[] tagkeys = new string[action.Tags.Count];
                    action.Tags.CopyTo(tagkeys, 0);

                    for (int j = 0; j < tagkeys.Length; ++j)
                    {
                        if (tagkeys[j].StartsWith("@"))
                        {
                            action.Tags.Remove(tagkeys[j]);
                        }
                    }

					if(_blocksRequested.Count > 0)
					{
						foreach (CFAction child in action.Children)
						{	
							bool childBlocked = false;
							
							foreach (string blockedTag in _blocksRequested)
							{
								if (child.Tags.Contains(blockedTag))
								{
									childBlocked = true;
									break;
								}
							}
							
							if(!childBlocked)
							{
								Add(child, action.Tags);
                                foreach (object cco in action.DataPipe)
                                {
                                    child.DataPipe.Enqueue(cco);
                                }
							}
						}
					}
					else if (action.Children.Count > 0)
	                {
	                    Add(action.Children, action.Tags);
                        foreach (CFAction child in action.Children)
                        {
                            foreach (object cco in action.DataPipe)
                            {
                                child.DataPipe.Enqueue(cco);
                            }
                        }
	                }
				}
				else
				{
					_actions.Enqueue(action);
				}
            }
		}
		
		private void ProcessAdditions()
		{
			while (_additions.Count > 0)
            {
                ICFTaggable obj = _additions.Dequeue();
				
				if(_blocksRequested.Count > 0)
				{
					bool skipTag = false;
					
					foreach (string tag in obj.Tags)
					{
						if(_blocksRequested.Contains(tag))
						{
							skipTag = true;
							break;
						}
					}
					
					if(skipTag)
					{
						continue;
					}
				}
				
				if(obj is CFAction)
				{
					_actions.Enqueue((CFAction)obj);
                    // good and bad could come from this coupling.
                    ((CFAction)obj).Engine = this;
				}
				
                Register(obj);
            }
		}
		
		private void ProcessResumeRequests()
		{
			foreach (string tag in _resumesRequested)
			{
			    if (_registry.ContainsKey(tag))
                {
                    foreach (ICFTaggable obj in _registry[tag])
                    {
						if(obj is ICFPausable)
						{
							((ICFPausable)obj).Paused = false;
						}
                    }
                }
            }
			
			_resumesRequested.Clear();
		}
		
		private void ProcessPauseRequests()
		{
			foreach (string tag in _pausesRequested)
			{
                if (_registry.ContainsKey(tag))
                {
                    foreach (ICFTaggable obj in _registry[tag])
                    {
						if(obj is ICFPausable)
						{
							((ICFPausable)obj).Paused = true;
						}
                    }
                }
            }
			
			_pausesRequested.Clear();
		}
		
        public void Update(float delta)
        {
            _delta = delta;

			ProcessDelayedFunctions();
			
			ProcessActions(delta);
			
			ProcessMessages();
			
			ProcessStopRequests();
			
			ProcessRemovals();
			
			ProcessAdditions();
			
			// pause and resume act on new additions intentionally.
			
			ProcessResumeRequests();
			
			ProcessPauseRequests();
			
			_blocksRequested.Clear();
        }
		
		#endregion
		
    }
}
