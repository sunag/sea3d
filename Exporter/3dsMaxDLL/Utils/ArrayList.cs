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
using NativeArrayList = System.Collections.ArrayList;

namespace Poonya.Utils
{
    public class ArrayList
    {
        private NativeArrayList list;

        public ArrayList()
        {
            list = new NativeArrayList();
        }

        public ArrayList(NativeArrayList list)
        {
            this.list = list;
        }

        public NativeArrayList data
        {
            get
            {
                return list;
            }
        }

        public void Swap(int source, int target)
        {
            object val = list[source];
            list[source] = list[target];
            list[target] = val;
        }

        public void Add(object value)
        {
            list.Add(value);
        }

        public void AddAt(object value, int index)
        {
            list.Insert(index, value);
        }

        public void RemoveAt(int index)
        {
            list.RemoveAt(index);
        }

        public object Get(int index)
        {
            return list[index];
        }

        public int Length
        {
            get
            {
                return list.Count;
            }
        }
    }
}
