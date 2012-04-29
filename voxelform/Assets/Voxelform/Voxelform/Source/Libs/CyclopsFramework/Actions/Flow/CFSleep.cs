using System;
using System.Collections.Generic;
using System.Text;
using CyclopsFramework.Core;

namespace CyclopsFramework.Actions.Flow
{
    public class CFSleep:CFAction
    {
        public const string TAG = "@CFSleep";
		
        public CFSleep(float period) : base(period, 1, null, TAG)
        {
			
        }
    }
}
