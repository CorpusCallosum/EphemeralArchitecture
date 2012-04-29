using System;
using System.Collections.Generic;
using System.Text;
using CyclopsFramework.Core;

namespace CyclopsFramework.Actions.Flow
{
    public class CFFunction : CFAction
    {
        public const string TAG = "@CFFunction";
		
		public delegate void F();
		public delegate void Fd(object data);
		private object _data;
		
		F _f;
		Fd _fd;
		
        public CFFunction(F f) : base(1, 0, null, TAG)
        {
			_f = f;
        }
		
		public CFFunction(object data, Fd f) : base(1, 0, null, TAG)
        {
			_data = data;
			_fd = f;
        }
		
		public CFFunction(float period, float cycles, F f) : base(period, cycles, null, TAG)
        {
			_f = f;
        }
		
		public CFFunction(float period, float cycles, object data, Fd f) : base(period, cycles, null, TAG)
        {
			_data = data;
			_fd = f;
        }
		
		protected override void OnFirstFrame ()
		{
			if (_data != null)
			{
				_fd(_data);
			}
			else
			{
				_f();
			}
		}

    }
}
