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

namespace Poonya.Utils
{
    public static class Base64
    {
        public static string Encode(string stringToEncode)
        {
            // Converte a String num Array de Bytes obdecendo o Encode ASCII.
            byte[] EncodeBytes = UnicodeEncoding.Unicode.GetBytes(stringToEncode);

            // Converte o Array de Bytes em String no formato Base64.
            return Convert.ToBase64String(EncodeBytes);
        }

        public static string Decode(string stringEncoded)
        {
            // Converte a String em Base64 em Array de Bytes.
            byte[] encodedDataAsBytes = System.Convert.FromBase64String(stringEncoded);

            // Retorna a String decodificada.
            return UnicodeEncoding.Unicode.GetString(encodedDataAsBytes);
        }
    }
}
