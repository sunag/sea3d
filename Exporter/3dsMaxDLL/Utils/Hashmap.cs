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
using System.Collections.Generic;
using System;
using System.Globalization;
using System.Collections;

namespace Poonya.Utils
{
    public class Hashmap
    {
        private Dictionary<string, string> vars = new Dictionary<string, string>();

        public Dictionary<string, string> data
        {
            get
            {
                return vars;
            }
        }

        public void AddString(string name, string value)
        {
            Remove(name);
            vars.Add(name, value.Trim());
        }

        public bool Contains(string name)
        {
            return vars.ContainsKey(name);
        }

        public string GetString(string name)
        {
            if (!vars.ContainsKey(name)) return "";
            return vars[name];
        }

        public void AddFloat(string name, float value)
        {
            Remove(name);
            vars.Add(name, value.ToString().Replace(',', '.'));
        }

        public void Remove(string name)
        {
            if (vars.ContainsKey(name))
                vars.Remove(name);
        }

        public float GetFloat(string name)
        {
            try { return float.Parse(vars[name], CultureInfo.InvariantCulture); }
            catch (Exception) { return 0.0f; }
        }

        public void AddBoolean(string name, bool value)
        {
            Remove(name);
            vars.Add(name, value ? "true" : "false");
        }

        public bool GetBoolean(string name)
        {
            try { return bool.Parse(vars[name]); }
            catch (Exception) { return false; }
        }

        public void AddInteger(string name, int value)
        {
            Remove(name);
            vars.Add(name, value.ToString());
        }

        public int GetInteger(string name)
        {
            try { return int.Parse(vars[name]); }
            catch (Exception) { return 0; }
        }

        public bool ContainsFile(string filename)
        {
            return System.IO.File.Exists(filename);
        }

        public void AddColor(string name, int r, int g, int b)
        {
            Remove(name);
            vars.Add(name, r.ToString() + ' ' + g.ToString() + ' ' + b.ToString());
        }

        public int GetColor(string name, int color)
        {
            try { return int.Parse(vars[name].Split(' ')[color]); }
            catch (Exception) { return 0; }
        }

        public int GetRed(string name)
        {
            return GetColor(name, 0);
        }

        public int GetGreen(string name)
        {
            return GetColor(name, 1);
        }

        public int GetBlue(string name)
        {
            return GetColor(name, 2);
        }

        public void Load(string filename)
        {
            Clear();

            Merge(filename);
        }

        public void Merge(string filename)
        {
            using (var sw = new StreamReader(filename, new UTF8Encoding(false)))
            {
                Read(sw.ReadToEnd());
            }
        }

        public void Read(string hash)
        {
            string[] config = hash.Split('\n');

            foreach (string line in config)
            {
                if (line.Contains("="))
                {
                    int index = line.IndexOf('=');

                    string name = line.Substring(0, index).Trim();
                    string value = line.Substring(index + 1).Trim();

                    if (vars.ContainsKey(name))
                        vars.Remove(name);

                    vars.Add(name, value);
                }
            }
        }

        public void Save(string filename)
        {
            using (FileStream s = System.IO.File.Create(filename))
            {
                using (StreamWriter sw = new StreamWriter(s, new UTF8Encoding(false)))
                {
                    sw.Write(ToString());
                }
            }            
        }

        override public string ToString()
        {
            StringBuilder sb = new StringBuilder();

            foreach (KeyValuePair<string, string> pair in vars)
            {                
                sb.AppendFormat("{0} = {1}" + Environment.NewLine,
                    pair.Key,
                    pair.Value);
            }

            return sb.ToString();
        }

        public string ToBase64()
        {
            return Base64.Encode(ToString());
        }

        public void Clear()
        {
            vars.Clear();
        }

        public void ReadBase64(string base64)
        {
            Read(Base64.Decode(base64));
        }
    }
}
