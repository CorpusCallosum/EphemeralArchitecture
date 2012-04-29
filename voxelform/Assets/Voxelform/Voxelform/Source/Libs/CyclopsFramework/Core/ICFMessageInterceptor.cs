using System;

namespace CyclopsFramework.Core
{
	interface ICFMessageInterceptor
	{
		void InterceptMessage(CFMessage msg);
	}
}
