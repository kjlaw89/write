/***
    Copyright (C) 2013-2014 Write Developers

    This program or library is free software; you can redistribute it
    and/or modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 3 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    Lesser General Public License for more details.
 
    You should have received a copy of the GNU Lesser General
    Public License along with this library; if not, write to the
    Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301 USA.

    Authored by: KJ Lawrence <kjtehprogrammer@gmail.com>
***/

namespace Write
{
	public class TextStyle 
	{
		private string data = "";
		
		public string Name { get; private set; }
		public string Description { get; private set; }
		public string Data { get { return data; } }
		
		private static Gee.HashMap<string, TextStyle> styles = new Gee.HashMap<string, TextStyle>();
		public static Gee.HashMap<string, TextStyle> Styles
		{
			get { return styles; }
		}
		
		private TextStyle() {}
		
		public TextStyle.load_from_resource(string resource_name)
		{
			var stream = Write.Window.Resources.open_stream(resource_name, GLib.ResourceLookupFlags.NONE);
			load_from_stream(stream);
		}
		
		public TextStyle.load_from_file(string filename)
		{
		}
		
		public TextStyle.load_from_stream(InputStream stream)
		{
			var dataStream = new GLib.DataInputStream(stream);
			
			string? line = null;
			while ((line = dataStream.read_line(null, null)) != null)
			{				
				// Parse out the name of the style
				if (Name == null && "Style Name:" in line)
				{
					Name = line.slice(line.index_of("Style Name:") + 12, line.index_of("*/")).strip();
					
					// Once we have the name, verify that we do not already have this particular style in memory
					if (TextStyle.Styles.has_key(Name))
					{
						var style = TextStyle.Styles.get(Name);
						Description = style.Description;
						data = style.Data;
						
						return;
					}
					
					continue;
				}
				
				if (Description == null && "Description:" in line)
				{
					Description = line.slice(line.index_of("Description:") + 12, line.index_of("*/"));
					continue;
				}
					
				data += line + "\n";
			}
			
			TextStyle.Styles.set(Name, this);
		}
	}
}
