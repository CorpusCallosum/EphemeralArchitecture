using System;
using System.Collections.Generic;
using System.Reflection;
using CyclopsFramework.Core;
using CyclopsFramework.Core.Easing;

namespace CyclopsFramework.Actions.Interpolation
{

	public class CFInterpolate1B : CFAction
	{
		public const string TAG = "@CFInterpolate1B";
		
		object _targetObject;
        IEnumerable<string> _targetTags;
		string _propertyName;
		float _value1;
		float _value2;
        PropertyInfo _pinfo;
        FieldInfo _finfo;
        
        public CFInterpolate1B(
		    object targetObject,
            string propertyName,
		    byte value1,
		    byte value2,
		    float period,
		    float cycles,
		    CFBias.FofT bias)
            :base(period, cycles, bias, TAG)
        {
			_targetObject = targetObject;
			_propertyName = propertyName;
			_value1 = (float)value1;
			_value2 = (float)value2;
			_pinfo = _targetObject.GetType().GetProperty(_propertyName);
            _finfo = _targetObject.GetType().GetField(_propertyName);
		}

        public CFInterpolate1B(
            string targetTags,
            string propertyName,
            byte value1,
            byte value2,
            float period,
            float cycles,
            CFBias.FofT bias)
            : base(period, cycles, bias, TAG)
        {
            _targetTags = new[] {targetTags};
            _propertyName = propertyName;
            _value1 = (float)value1;
            _value2 = (float)value2;
        }

        public CFInterpolate1B(
            IEnumerable<string> targetTags,
            string propertyName,
            byte value1,
            byte value2,
            float period,
            float cycles,
            CFBias.FofT bias)
            : base(period, cycles, bias, TAG)
        {
            _targetTags = targetTags;
            _propertyName = propertyName;
            _value1 = (float)value1;
            _value2 = (float)value2;
        }

		protected override void OnFrame(float t)
		{
            if (_targetTags != null)
            {
                foreach (ICFTaggable item in Engine.Filter(_targetTags))
                {
                    var finfo = item.GetType().GetField(_propertyName);
                    if (finfo != null)
                    {
                        finfo.SetValue(item, (byte)(_value1 + (_value2 - _value1) * t));
                    }
                    else
                    {
                        var pinfo = item.GetType().GetProperty(_propertyName);
                        if (pinfo != null)
                        {
                            pinfo.SetValue(item, (byte)(_value1 + (_value2 - _value1) * t), null);
                        }
                    }
                }
            }
            else if (_finfo != null)
            {
                _finfo.SetValue(_targetObject, (byte)(_value1 + (_value2 - _value1) * t));
            }
            else
            {
                _pinfo.SetValue(_targetObject, (byte)(_value1 + (_value2 - _value1) * t), null);
            }
		}

	}
}
