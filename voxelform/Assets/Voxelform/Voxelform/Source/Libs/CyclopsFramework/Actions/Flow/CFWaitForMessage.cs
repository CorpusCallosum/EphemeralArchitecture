using System;
using System.Collections.Generic;
using System.Text;
using CyclopsFramework.Core;

namespace CyclopsFramework.Actions.Flow
{
    public class CFWaitForMessage : CFAction, ICFMessageInterceptor
    {
        public const string TAG = "@CFWaitForMessage";

        public delegate void Fd(CFMessage msg);
        public delegate void FTimeOut();

        string _messageName = null;
        Fd _fd = null;
        FTimeOut _timeoutListener = null;
        bool _timedOut = true;

        public CFWaitForMessage(string messageName)
            : base(float.MaxValue, 1f, null, TAG)
        {
            _messageName = messageName;
        }

        public CFWaitForMessage(string messageName, float timeout, float cycles)
            : base(timeout, cycles, null, TAG)
        {
            _messageName = messageName;
        }

        public CFWaitForMessage(string messageName, float timeout, float cycles, Fd f)
            : base(timeout, cycles, null, TAG)
        {
            _messageName = messageName;
            _fd = f;
        }

        public CFWaitForMessage(string messageName, float timeout, float cycles, Fd f, FTimeOut timeoutListener)
            : base(timeout, cycles, null, TAG)
        {
            _messageName = messageName;
            _fd = f;
        }

        public void InterceptMessage(CFMessage msg)
        {
            if ((_messageName == null) || (_messageName == msg.Name))
            {
                _timedOut = false;
                if (_fd != null) _fd(msg);
                this.Stop();
            }
        }

        protected override void OnLastFrame()
        {
            if ((_timeoutListener != null) && _timedOut) _timeoutListener();
        }

    }
}