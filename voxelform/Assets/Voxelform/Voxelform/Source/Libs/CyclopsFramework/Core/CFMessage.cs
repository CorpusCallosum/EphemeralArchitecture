using System;
using System.Collections.Generic;
using System.Text;

namespace CyclopsFramework.Core
{
	public class CFMessage
	{
        private string _receiverTag;
		public string ReceiverTag
        {
            get { return _receiverTag; }
            set { _receiverTag = value; }
        }

        private string _name;
		public string Name
        {
            get { return _name; }
            set { _name = value; }
        }

        private object[] _data;
		public object[] Data
        {
            get { return _data; }
            set { _data = value; }
        }

        private object _sender;
        public object Sender
        {
            get { return _sender; }
            set { _sender = value; }
        }

        private Type _receiverType;
		public Type ReceiverType
        {
            get { return _receiverType; }
            set { _receiverType = value; }
        }
		
		private bool _canceled = false;
		public bool IsCanceled { get { return _canceled; } }
			
		public CFMessage(string receiverTag, string name, object[] data, object sender, Type receiverType)
		{
			ReceiverTag = receiverTag;
			Name = name;
			Data = data;
			Sender = sender;
			ReceiverType = receiverType;
		}
		
		public void Cancel()
		{
			_canceled = true;
		}
		
	}
}
