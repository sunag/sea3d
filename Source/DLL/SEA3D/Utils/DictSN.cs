using System;
using System.Collections.Generic;
using System.Text;

namespace Poonya.Utils
{
    public class DictSN
    {
        private Dictionary<string, uint> dict = new Dictionary<string, uint>();

        public void Add(string name, uint value)
        {
            dict.Add(name, value);
        }

        public bool Contains(string name)
        {
            return dict.ContainsKey(name);
        }

        public uint Get(string name)
        {
            return dict[name];
        }
    }
}
