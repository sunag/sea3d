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
using System.Linq;
using System.Text;
using Poonya.SEA3D;
using Poonya.SEA3D.Objects;
using System.Threading;
using Sunag.SEA3D;
using Poonya.Utils;

namespace SEA3D_Console
{
    class Program
    {
        static void Main(string[] args)
        {
            SEA3DAssimp importer = new SEA3DAssimp();

            string openFile = null;
            string saveFile = null;

            for (int i = 0; i < args.Length; i++)
            {
                if (args[i] == "-normals")
                {
                    importer.CalculateNormal = !importer.CalculateNormal;
                }
                else if (args[i] == "-modifiers")
                {
                    importer.Modifiers = !importer.Modifiers;
                }
                else if (args[i] == "-tangents")
                {
                    importer.CalculateTangent = !importer.CalculateTangent;
                }
                else if (args[i] == "-optimize" && i + 1 < args.Length)
                {
                    importer.OptimizeLevel = int.Parse(args[++i]);
                }
                else if (args[i] == "-open" && i + 1 < args.Length)
                {
                    openFile = args[++i];
                }
                else if (args[i] == "-save" && i + 1 < args.Length)
                {
                    saveFile = args[++i];
                }
            }

            if (openFile != null && saveFile != null)
            {
                importer.Import(openFile);
                importer.Save(saveFile);
            }
            else
            {
                importer.LoadSave();
            }
        }        
    }
}
