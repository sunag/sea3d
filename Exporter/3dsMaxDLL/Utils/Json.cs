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

using System;
using System.Collections.Generic;
using System.Text;
using NativeHashtable = System.Collections.Hashtable;
using NativeArrayList = System.Collections.ArrayList;
using DictionaryEntry = System.Collections.DictionaryEntry;

// https://bitbucket.org/bitsquid/json_merger/src/50f1783ab4a2/json_merge/JSON.cs

namespace Poonya.Utils
{
    /// <summary>
    /// Provides functions for encoding and decoding files in the JSON format.
    /// </summary>
    public class Json
    {
        /// <summary>
        ///  Encodes the hashtable t in the JSON format. The hash table can
        ///  contain, numbers, bools, strings, ArrayLists and Hashtables.
        /// </summary>
        public static string Encode(object t)
        {
            StringBuilder builder = new StringBuilder();
            Write(t, builder, 0);
            return builder.ToString();
        }

        /// <summary>
        /// Decodes a JSON bytestream into a hash table with numbers, bools, strings, 
        /// ArrayLists and Hashtables.
        /// </summary>
        public static object Decode(byte[] sjson)
        {
            int index = 0;
            return Parse(sjson, ref index);
        }

        /// <summary>
        /// Convenience function for loading a file.
        /// </summary>
        public static Hashtable Load(string path)
        {
            System.IO.FileStream fs = System.IO.File.Open(path, System.IO.FileMode.Open, System.IO.FileAccess.Read);
            byte[] bytes = new byte[fs.Length];
            fs.Read(bytes, 0, bytes.Length);
            fs.Close();
            return Decode(bytes) as Hashtable;
        }

        /// <summary>
        /// Convenience function for saving a file.
        /// </summary>
        public static void Save(Hashtable h, string path)
        {
            string s = Encode(h);
            System.IO.FileStream fs = System.IO.File.Open(path, System.IO.FileMode.Create);
            byte[] bytes = System.Text.Encoding.UTF8.GetBytes(s);
            fs.Write(bytes, 0, bytes.Length);
            fs.Close();
        }

        /// <summary>
        /// Writes a newline and the desired ammount of indentation.
        /// </summary>
        public static void WriteNewLine(StringBuilder builder, int indentation)
        {
            builder.Append('\n');
            for (int i = 0; i < indentation; ++i)
                builder.Append("    ");
        }

        /// <summary>
        /// Writes a generic object.
        /// </summary>
        public static void Write(object o, StringBuilder builder, int indentation)
        {
            // Native
            if (o == null)
                builder.Append("null");
            else if (o is Boolean && (bool)o == false)
                builder.Append("false");
            else if (o is Boolean)
                builder.Append("true");
            else if (o is int)
                builder.Append((int)o);
            else if (o is float || o is double)
                builder.Append(o.ToString().Replace(',', '.'));
            else if (o is string)
                WriteString((String)o, builder);
            /*
            else if (o is NativeArrayList)
                WriteArray((NativeArrayList)o, builder, indentation);
            else if (o is NativeHashtable)
                WriteObject((NativeHashtable)o, builder, indentation);
            */
            // Sunag.IO
            else if (o is Hashtable)
                WriteObject((o as Hashtable).data, builder, indentation);
            else if (o is ArrayList)
                WriteArray((o as ArrayList).data, builder, indentation);
            else
                throw new ArgumentException("Unknown object");
        }

        /// <summary>
        /// Writes a string.
        /// </summary>
        public static void WriteString(String s, StringBuilder builder)
        {
            builder.Append('"');
            for (int i = 0; i < s.Length; ++i)
            {
                Char c = s[i];
                if (c == '"' || c == '\\')
                {
                    builder.Append('\\');
                    builder.Append(c);
                }
                else if (c == '\n')
                {
                    builder.Append('\\');
                    builder.Append('n');
                }
                else
                    builder.Append(c);
            }
            builder.Append('"');
        }

        /// <summary>
        /// Writes an array of items.
        /// </summary>
        public static void WriteArray(NativeArrayList a, StringBuilder builder, int indentation)
        {
            bool write_comma = false;
            builder.Append('[');
            foreach (object item in a)
            {
                if (write_comma)
                    builder.Append(',');
                WriteNewLine(builder, indentation + 1);
                Write(item, builder, indentation + 1);
                write_comma = true;

            }
            WriteNewLine(builder, indentation);
            builder.Append(']');
        }

        /// <summary>
        /// Writes a particular field in a JSON object.
        /// </summary>
        public static void WriteObjectField(NativeHashtable t, string key, bool write_comma, StringBuilder builder, int indentation)
        {
            if (write_comma)
                builder.Append(", ");
            WriteNewLine(builder, indentation);
            Write(key, builder, indentation);
            builder.Append(" : ");
            Write(t[key], builder, indentation);
        }

        /// <summary>
        /// Writes all the fields of a JSON object.
        /// </summary>
        public static void WriteObjectFields(NativeHashtable t, StringBuilder builder, int indentation)
        {
            bool write_comma = false;

            foreach (DictionaryEntry e in t)
            {
                WriteObjectField(t, e.Key.ToString(), write_comma, builder, indentation);
                write_comma = true;
            }
        }

        /// <summary>
        /// Writes a JSON object.
        /// </summary>
        public static void WriteObject(NativeHashtable t, StringBuilder builder, int indentation)
        {
            builder.Append('{');
            WriteObjectFields(t, builder, indentation + 1);
            WriteNewLine(builder, indentation);
            builder.Append('}');
        }

        static bool AtEnd(byte[] json, ref int index)
        {
            SkipWhitespace(json, ref index);
            return (index >= json.Length);
        }

        static void SkipWhitespace(byte[] json, ref int index)
        {
            while (index < json.Length)
            {
                byte c = json[index];
                if (c == ' ' || c == '\t' || c == '\n' || c == '\r' || c == ',')
                    ++index;
                else
                    break;
            }
        }

        static void Consume(byte[] json, ref int index, String consume)
        {
            SkipWhitespace(json, ref index);
            for (int i = 0; i < consume.Length; ++i)
            {
                if (json[index] != consume[i])
                    throw new FormatException();
                ++index;
            }
        }

        static object Parse(byte[] json, ref int index)
        {
            byte c = Next(json, ref index);

            if (c == '{')
                return ParseObject(json, ref index);
            else if (c == '[')
                return ParseArray(json, ref index);
            else if (c == '"')
                return ParseString(json, ref index);
            else if (c == '-' || c >= '0' && c <= '9')
                return ParseNumber(json, ref index);
            else if (c == 't')
            {
                Consume(json, ref index, "true");
                return true;
            }
            else if (c == 'f')
            {
                Consume(json, ref index, "false");
                return false;
            }
            else if (c == 'n')
            {
                Consume(json, ref index, "null");
                return null;
            }
            else
                throw new FormatException();
        }

        static byte Next(byte[] json, ref int index)
        {
            SkipWhitespace(json, ref index);
            return json[index];
        }

        static Hashtable ParseObject(byte[] json, ref int index)
        {
            NativeHashtable ht = new NativeHashtable();
            Consume(json, ref index, "{");
            SkipWhitespace(json, ref index);

            while (Next(json, ref index) != '}')
            {
                String key = ParseString(json, ref index);
                Consume(json, ref index, ":");
                if (key.EndsWith("_binary"))
                    ht[key] = ParseBinary(json, ref index);
                else
                    ht[key] = Parse(json, ref index);
            }
            Consume(json, ref index, "}");
            return new Hashtable(ht);
        }

        static ArrayList ParseArray(byte[] json, ref int index)
        {
            NativeArrayList a = new NativeArrayList();
            Consume(json, ref index, "[");
            while (Next(json, ref index) != ']')
            {
                object value = Parse(json, ref index);
                a.Add(value);
            }
            Consume(json, ref index, "]");
            return new ArrayList(a);
        }

        static byte[] ParseBinary(byte[] json, ref int index)
        {
            List<byte> s = new List<byte>();

            Consume(json, ref index, "\"");
            while (true)
            {
                byte c = json[index];
                ++index;
                if (c == '"')
                    break;
                else if (c != '\\')
                    s.Add(c);
                else
                {
                    byte q = json[index];
                    ++index;
                    if (q == '"' || q == '\\' || q == '/')
                        s.Add(q);
                    else if (q == 'b') s.Add((byte)'\b');
                    else if (q == 'f') s.Add((byte)'\f');
                    else if (q == 'n') s.Add((byte)'\n');
                    else if (q == 'r') s.Add((byte)'\r');
                    else if (q == 't') s.Add((byte)'\t');
                    else if (q == 'u')
                    {
                        throw new FormatException();
                    }
                    else
                    {
                        throw new FormatException();
                    }
                }
            }
            return s.ToArray();
        }

        static String ParseString(byte[] json, ref int index)
        {
            return new UTF8Encoding().GetString(ParseBinary(json, ref index));
        }

        static Double ParseNumber(byte[] json, ref int index)
        {
            int end = index;
            while ("0123456789+-.eE".IndexOf((char)json[end]) != -1)
                ++end;
            byte[] num = new byte[end - index];
            Array.Copy(json, index, num, 0, num.Length);
            index = end;
            String numstr = new UTF8Encoding().GetString(num);
            return Double.Parse(numstr);
        }
    }
}
