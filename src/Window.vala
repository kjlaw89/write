/***
    Copyright (C) 2013-2014 Activities Developers

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

using Granite;
using Granite.Widgets;
using Gee;
using WebKit;

namespace Write
{
	/**
	 * Application Window for Write
	 * Initializes a window with an integrated toolbar
	 *
	 * This class will facilitate communications between all
	 * of the individual elements in the program through various
	 * methods and exposure of elements when necessary.
	 *
	 * Structure:
	 *	<Gtk.Window>
	 *	</Gtk.Window>
	 */
	public class Window : Gtk.Window
	{
		public Granite.Application Application { get; private set; }
		public DocumentToolbar WindowBar;
		public ContextToolbar ContextBar;
		public DocumentView View;
		
		private static GLib.Resource resources;
		public static GLib.Resource Resources
		{
			get
			{
				if (resources == null)
				{
					try { resources = GLib.Resource.load("appresources"); }
					catch (Error error) { stdout.printf("Unable to load application resources. Closing... " + error.message); }
				}
					
				return resources;
			}
		}
		
		public static string GetResourceAsString(string resource)
		{
		
			string data = "";
			var stream = new GLib.DataInputStream(Window.Resources.open_stream(resource, GLib.ResourceLookupFlags.NONE));
			
			string? line = null;
			while ((line = stream.read_line(null, null)) != null)
				data += line + "\n";
				
			return data;
		}

 		/**
 		 * Initializes the main window for the application
 		 */
		public Window(Granite.Application application)
		{
			Application = application;
			title = "Write";
			set_application(application);
			set_default_size(986, 512);
			window_position = Gtk.WindowPosition.CENTER;
			
			// Load in our application's CSS
			try
			{
				var css = new Gtk.CssProvider();
				css.load_from_data(Window.GetResourceAsString("/org/elementary/write/app.css"), -1);
				Gtk.StyleContext.add_provider_for_screen(screen, css, Gtk.STYLE_PROVIDER_PRIORITY_THEME);
			}
			catch (Error ex) { }
			
			// Initialize our UI elements
			WindowBar = new DocumentToolbar(this);
			ContextBar = new ContextToolbar(this);
			View = new DocumentView(this);
			
			var scroll = new Gtk.ScrolledWindow(null, null);
			scroll.expand = true;
			scroll.add(View);

			var content = new Gtk.Grid();
			content.expand = true;
			content.orientation = Gtk.Orientation.VERTICAL;
			content.add(WindowBar);
			content.add(ContextBar);
			content.add(scroll);
			content.show_all();

			add(content);
			show_all();
		}
	}
}
