using System;
using System.Collections.Generic;
using System.Reflection;
using CyclopsFramework.Core;
using CyclopsFramework.Core.Easing;

namespace CyclopsFramework.Actions.Interpolation
{
	public class CFInterpolate<T> : CFAction
	{
        public const string TAG = "@CFInterpolate";
				
		object _targetObject;
        IEnumerable<string> _targetTags;
		string _propertyName;
		double _value1;
		double _value2;
		T _tvalue1;
		T _tvalue2;
		PropertyInfo _pinfo;
        FieldInfo _finfo;
				
        public CFInterpolate(
		    object targetObject,
            string propertyName,
		    double value1,
		    double value2,
		    float period,
		    float cycles,
		    CFBias.FofT bias)
            :base(period, cycles, bias, TAG)
        {
			_targetObject = targetObject;
			_propertyName = propertyName;
			_value1 = value1;
			_value2 = value2;
			_pinfo = _targetObject.GetType().GetProperty(_propertyName);
            _finfo = _targetObject.GetType().GetField(_propertyName);
			
		}

        public CFInterpolate(
            string targetTag,
            string propertyName,
            double value1,
            double value2,
            float period,
            float cycles,
            CFBias.FofT bias)
            : base(period, cycles, bias, TAG)
        {
            _targetTags = new[] {targetTag};
            _propertyName = propertyName;
            _value1 = value1;
			_value2 = value2;
        }

        public CFInterpolate(
            IEnumerable<string> targetTags,
            string propertyName,
            double value1,
            double value2,
            float period,
            float cycles,
            CFBias.FofT bias)
            : base(period, cycles, bias, TAG)
        {
            _targetTags = targetTags;
            _propertyName = propertyName;
            _value1 = value1;
			_value2 = value2;
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
                        finfo.SetValue(item, D2T(_value1 + (_value2 - _value1) * t));
                    }
                    else
                    {
                        var pinfo = item.GetType().GetProperty(_propertyName);
                        if (pinfo != null)
                        {
                            pinfo.SetValue(item, D2T(_value1 + (_value2 - _value1) * t), null);
                        }
                    }
                }
            }
            else if (_finfo != null)
            {
                _finfo.SetValue(_targetObject, D2T(_value1 + (_value2 - _value1) * t));
            }
            else
            {
                _pinfo.SetValue(_targetObject, D2T(_value1 + (_value2 - _value1) * t), null);
            }
        }
		
		private object D2T(double n)
		{
			switch(Type.GetTypeCode(typeof(T)))
			{
				case TypeCode.Single: return Convert.ToSingle(n);
				case TypeCode.Double: return Convert.ToDouble(n);
				case TypeCode.Int32: return Convert.ToInt32(n);
				case TypeCode.UInt32: return Convert.ToUInt32(n);
				case TypeCode.Byte: return Convert.ToByte(n);
				case TypeCode.Char: return Convert.ToChar(n);
				case TypeCode.Int16: return Convert.ToInt16(n);
				case TypeCode.Int64: return Convert.ToInt64(n);
				case TypeCode.SByte: return Convert.ToSByte(n);
				case TypeCode.UInt16: return Convert.ToUInt16(n);
				case TypeCode.UInt64: return Convert.ToUInt64(n);
				case TypeCode.Decimal: return Convert.ToDecimal(n);
				case TypeCode.String: return Convert.ToString(n);		
				case TypeCode.Boolean: return Convert.ToBoolean(n);
				default: throw new InvalidCastException(String.Format("Conversion to {0} is not supported.", typeof(T).Name));
			}
		}

    }
}
