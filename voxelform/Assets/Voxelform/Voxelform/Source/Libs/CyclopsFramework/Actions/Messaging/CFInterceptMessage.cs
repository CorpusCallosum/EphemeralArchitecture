using System;
using System.Collections.Generic;
using System.Text;
using CyclopsFramework.Core;

namespace CyclopsFramework.Actions.Messaging
{
	public class CFInterceptMessage : CFAction, ICFMessageInterceptor
	{
        public const string TAG = "@CFInterceptMessage";
		
		public delegate void Fd(CFMessage msg);
		
		Fd _fd;
		
		public CFInterceptMessage(float period, float cycles, Fd f) : base(period, cycles, null, TAG)
        {
			_fd = f;
        }
		
		public void InterceptMessage (CFMessage msg)
		{
			_fd(msg);
		}

	}
}
