/*
*
* Copyright (c) Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

using System.IO;
using System.Text;
using System;
using System.Globalization;
using NativeHashtable = System.Collections.Hashtable;

namespace Poonya.Utils
{
    public class Hashtable
    {
        private NativeHashtable table;

        public Hashtable()
        {
            table = new NativeHashtable();
        }

        public Hashtable(NativeHashtable table)
        {
            this.table = table;
        }

        public NativeHashtable data
        {
            get
            {
                return table;
            }
        }

        public void Add(string name, object value)
        {
            Remove(name);
            table.Add(name, value);
        }

        public bool Contains(string name)
        {
            return table.ContainsKey(name);
        }

        public void Remove(string name)
        {
            if (table.ContainsKey(name))
                table.Remove(name);
        }

        public object Get(string name)
        {
            return table[name];
        }

        public object GetDef(string name, object def)
        {
            if (table.ContainsKey(name))
                return table[name];
            else return def;            
        }

        public bool ContainsFile(string filename)
        {
            return System.IO.File.Exists(filename);
        }

        public void Load(string filename)
        {
            table.Clear();
            Merge(filename);
        }

        public string ToJson()
        {
            return Json.Encode(this);
        }

        public void ReadJson(string json)
        {
            Merge(Json.Decode(Encoding.UTF8.GetBytes(json)) as Hashtable);
        }

        public void ReadBase64(string base64)
        {
            ReadJson( Base64.Decode(base64) );
        }

        public string ToBase64()
        {
            return Base64.Encode(ToJson());
        }

        public void Merge(Hashtable hash)
        {
            foreach (string key in hash.data.Keys)
            {
                Add(key, hash.data[key]);
            }
        }

        public void Merge(string filename)
        {
            Merge( Json.Load(filename) );
        }

        public void Save(string filename)
        {
            using (FileStream s = System.IO.File.Create(filename))
            {
                using (StreamWriter sw = new StreamWriter(s, new UTF8Encoding(false)))
                {
                    sw.Write(ToJson());
                }
            }            
        }
    }
}
