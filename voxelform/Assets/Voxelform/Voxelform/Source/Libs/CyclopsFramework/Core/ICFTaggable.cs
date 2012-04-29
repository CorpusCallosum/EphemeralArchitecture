using System;
using System.Collections.Generic;

namespace CyclopsFramework.Core
{
	public interface ICFTaggable
	{
		HashSet<string> Tags { get; }
	}
}
