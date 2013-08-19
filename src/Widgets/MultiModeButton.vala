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
	public class MultiModeButton : Gtk.Box
	{
		private class Item : Gtk.ToggleButton
		{
            public int index { get; construct; }
            public Item (int index)
            {
                Object (index: index);
                can_focus = false;
            }
        }

        public signal void mode_added (int index, Gtk.Widget widget);
        public signal void mode_removed (int index, Gtk.Widget widget);
        public signal void mode_changed (Gtk.Widget widget);

        /**
         * Read-only length of current ModeButton
         */
        public uint n_items
        {
            get { return item_map.size; }
        }

        private Gee.HashMap<int, Item> item_map;

        /**
         * Makes new ModeButton
         */
        public MultiModeButton ()
        {
            homogeneous = true;
            spacing = 0;
            can_focus = false;

            item_map = new Gee.HashMap<int, Item> ();

            var style = get_style_context ();
            style.add_class (Gtk.STYLE_CLASS_LINKED);
            style.add_class ("raised"); // needed for toolbars
        }

        /**
         * Appends Pixbuf to ModeButton
         *
         * @param pixbuf Gdk.Pixbuf to append to ModeButton
         */
        public int append_pixbuf (Gdk.Pixbuf pixbuf)
        {
            return append (new Gtk.Image.from_pixbuf (pixbuf));
        }

        /**
         * Appends text to ModeButton
         *
         * @param text text to append to ModeButton
         * @return index of new item
         */
        public int append_text (string text)
        {
            return append (new Gtk.Label(text));
        }

        /**
         * Appends icon to ModeButton
         *
         * @param icon_name name of icon to append
         * @param size desired size of icon
         * @return index of appended item
         */
        public int append_icon (string icon_name, Gtk.IconSize size)
        {
            return append (new Gtk.Image.from_icon_name (icon_name, size));
        }

        /**
         * Appends given widget to ModeButton
         *
         * @param w widget to add to ModeButton
         * @return index of new item
         */
        public int append (Gtk.Widget w)
        {
            int index;
            for (index = item_map.size; item_map.has_key (index); index++);
            	assert (item_map[index] == null);

            var item = new Item (index);
            item.add (w);

            item.button_press_event.connect (() =>
            {
               	set_active (item.index, !item.active);
                return true;
            });

            item_map[index] = item;

            add (item);
            item.show_all ();

            mode_added (index, w);

            return index;
        }

        /**
         * Sets item of given index's activity
         *
         * @param new_active_index index of changed item
         */
        public void set_active (int new_active_index, bool active, bool clicked = true)
        {
            return_if_fail (item_map.has_key (new_active_index));
            
            var new_item = item_map[new_active_index] as Item;
            if (new_item != null && new_item.active != active)
            {
                assert (new_item.index == new_active_index);

                if (active)
                {
                	new_item.set_active (true);
               		new_item.active = true;
                }
                else
                {
                	new_item.set_active (false);
               		new_item.active = false;
                }

				if (clicked)
                	mode_changed (new_item.get_child ());
            }
        }

        /**
         * Removes item at given index
         *
         * @param index index of item to remove
         */
        public new void remove (int index)
        {
            return_if_fail (item_map.has_key (index));
            var item = item_map[index] as Item;

            if (item != null)
            {
                assert (item.index == index);
                mode_removed (index, item.get_child ());
                item_map.unset (index);
                item.destroy ();
            }
        }

        /**
         * Clears all children
         */
        public void clear_children ()
        {
            foreach (weak Gtk.Widget button in get_children ())
            {
                button.hide ();
                if (button.get_parent () != null)
                    base.remove (button);
            }

            item_map.clear ();
        }
	}
}
