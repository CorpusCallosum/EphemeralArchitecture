using System;
using System.Collections.Generic;
using System.Reflection;
using CyclopsFramework.Core;
using CyclopsFramework.Core.Easing;

namespace CyclopsFramework.Actions.Interpolation
{
    public class CFFrameFunction : CFAction
    {
        public const string TAG = "@CFFrameFunction";

        public delegate void F();
        public delegate void FofT(float t);
        
        F _f = null;
        FofT _ft = null;

        public CFFrameFunction(
            float period,
            F f)
            : base(period, 1f, null, TAG)
        {
            _f = f;
        }

        public CFFrameFunction(
            float period,
            float cycles,
            CFBias.FofT bias,
            FofT ft)
            : base(period, cycles, bias, TAG)
        {
            _ft = ft;
        }

        protected override void OnFrame(float t)
        {
            if (_f != null)
            {
                _f();
            }
            else
            {
                _ft(t);
            }
        }

    }
}
