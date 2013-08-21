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

namespace Write
{
	/**
	 * Simple wrapper Widget for ComboBoxText
	 *
	 * Turns the widget into a simple Menu, where the first
	 * item is always shown even when another is selected and
	 * an event is thrown for any other menu item selected.
	 */
	public class ComboMenu : Gtk.ComboBoxText 
	{
		public signal void item_selected (int index);

		/**
		 * Creates a new Toolbar.
		 * @param css_class Style to apply to toolbar
		 * @param size Size to apply to icons
		 * @param spacing Spacing to put between each button
		 */ 
		public ComboMenu(string title)
		{
			append_text(title);
			active = 0;
			
			changed.connect(() => 
			{
				if (active == 0)
					return;
					
				item_selected(active);
				active = 0;
			});
		}
	}
}
