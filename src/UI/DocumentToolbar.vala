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
	public class DocumentToolbar : Toolbar
	{
		Write.Window Window { get; private set; }
	
 		/**
 		 * Initializes the main window toolbar for the application
 		 */
		public DocumentToolbar(Window window)
		{
			base("document-toolbar", false);
			this.Window = window;
			
			// Setup our New/Open/Save, etc. Buttons
			var newButton = new Gtk.ToolButton.from_stock (Gtk.Stock.NEW);
	        //newButton.clicked.connect(handle_new);
	        //newButton.add_accelerator("clicked", Window.AccelGroup, Gdk.Key.N, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);

	        // Create the open button and assign it it's primary method
	        var openButton = new Gtk.ToolButton.from_stock (Gtk.Stock.OPEN);
	        //openButton.clicked.connect(handle_open);
	        //openButton.add_accelerator("clicked", Window.AccelGroup, Gdk.Key.O, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
	        
	        var saveAsButton = new Gtk.ToolButton.from_stock (Gtk.Stock.SAVE_AS);
	        //saveAsButton.clicked.connect(handle_save_as);
	        //saveAsButton.add_accelerator("clicked", Window.AccelGroup, Gdk.Key.A, Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
	        
	        var documentButton = new Gtk.ToolButton.from_stock(Gtk.Stock.PAGE_SETUP);
	        var undoButton = new Gtk.ToolButton.from_stock(Gtk.Stock.UNDO);
	        var redoButton = new Gtk.ToolButton.from_stock(Gtk.Stock.REDO);
			
			// Setup our GEAR menu and Search Box
			Gtk.Menu settings = new Gtk.Menu ();
        	Gtk.MenuItem contractorItem = new Gtk.MenuItem.with_label("Send To...");
        	
        	Gtk.MenuItem printItem = new Gtk.MenuItem.with_label("Print...");
        	printItem.activate.connect(() => { Window.View.get_main_frame().print(); }); 
        	
        	Gtk.MenuItem aboutItem = new Gtk.MenuItem.with_label("About");
        	aboutItem.activate.connect(() => { Window.Application.show_about(Window); });
        	
        	// Add our settings items to our menu
        	settings.add(contractorItem);
        	settings.add(printItem);
        	settings.add(aboutItem);
        	var menuButton = new Granite.Widgets.ToolButtonWithMenu (new Gtk.Image.from_icon_name ("application-menu", Gtk.IconSize.LARGE_TOOLBAR), "", settings);       	
        	
        	var search = new Granite.Widgets.SearchBar("Search document...");
			search.text_changed_pause.connect((text) =>
			{
				var DOMWindow = Window.View.Document.default_view;
				DOMWindow.find(text, false, false, true, false, true, false);
			});
			
			search.activate.connect(() =>
			{
				var DOMWindow = Window.View.Document.default_view;
				DOMWindow.find(search.text, false, false, true, false, true, false);
			});
			
			add_left(newButton);
			add_left(openButton);
			add_left(saveAsButton);
			add_left(documentButton);
			add_left(undoButton);
			add_left(redoButton);
        	add_right(search);
        	add_right(menuButton);
		}
	}
}
