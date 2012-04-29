using System;
using System.Collections.Generic;
using System.Text;
using CyclopsFramework.Core;

namespace CyclopsFramework.Actions.Flow
{
    public class CFWaitUntil : CFAction
    {
        public const string TAG = "@CFWaitUntil";

        public delegate bool F();

        F _f;

        public CFWaitUntil(F f)
            : base(float.MaxValue, 1f, null, TAG)
        {
            _f = f;
        }

        public CFWaitUntil(F f, float timeout)
            : base(timeout, 1f, null, TAG)
        {
            _f = f;
        }

        protected override void  OnFrame(float t)
        {
            if (_f()) this.Stop();
        }

    }
}