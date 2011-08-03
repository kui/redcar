
module Redcar
  class ApplicationSWT
    class ToolBar

      DEFAULT_ICON = File.join(Redcar.root, %w(share icons document.png))

      def self.icons
        @icons = {
          :new => File.join(Redcar.icons_directory, "document-text.png"),
          :open => File.join(Redcar.icons_directory, "folder-open-document.png"),
          :open_dir => File.join(Redcar.icons_directory, "blue-folder-horizontal-open.png"),
          :save => File.join(Redcar.icons_directory, "disk.png"),
          :save_as => File.join(Redcar.icons_directory, "disk--plus.png"),
          #:save_all => File.join(ICONS_DIR, "save_all.png"),
          :undo => File.join(Redcar.icons_directory, "arrow-circle-225-left.png"),
          :redo => File.join(Redcar.icons_directory, "arrow-circle-315.png"),
          :search => File.join(Redcar.icons_directory, "binocular.png")
        }
      end

      def self.items
        @items ||= Hash.new {|h,k| h[k] = []}
      end

      def self.disable_items(key_string)
        items[key_string].each {|i| p i.text; i.enabled = false}
      end

      attr_reader :coolbar, :toolbar, :coolitem, :toolbars, :coolitems

      def initialize(window, toolbar_model, options={})
        # @toolbars = {}
        # @coolitems = {} 
        @entries = Hash.new {|h,k| h[k] = [] }
        @toolbar = window.shell.getToolBar
        p @toolbar
        # @coolbar = Swt::Widgets::CoolBar.new(window.shell, Swt::SWT::FLAT | Swt::SWT::HORIZONTAL)
        return unless toolbar_model
        toolbar_model.each do |entry|
          name = entry.barname || :new
          @entries[name] << entry
        #   name = entry.barname || :new
        #   if not @toolbars[name]
        #     if name == :core
        #       coolitem = Swt::Widgets::CoolItem.new(@coolbar, Swt::SWT::FLAT, 0)
        #     else
        #       coolitem = Swt::Widgets::CoolItem.new(@coolbar, Swt::SWT::FLAT)
        #     end
        #     
        #     @toolbars[name] = create_toolbar(@coolbar)
        #     @coolitems[name] = coolitem
        #   else
        #     @toolbar = @toolbars[name]
        #     coolitem = @coolitems[name]
        #   end
        end
        add_entries_to_toolbar(@toolbar, @entries[:core])
        @entries.each do |name, es|
          next if name == :core
          add_entries_to_toolbar(@toolbar, es)
          sep = Swt::Widgets::ToolItem.new(@toolbar, Swt::SWT::DEFAULT)
        end
        # @toolbars.each do |name, toolbar|
        #   coolitem = @coolitems[name]
        #   toolbar_data = @entries[name]
        #   coolitem.setControl(toolbar)
        # 
        #   p = toolbar.computeSize(Swt::SWT::DEFAULT, Swt::SWT::DEFAULT)
        #   point = coolitem.computeSize(p.x, p.y)
        #   coolitem.setSize(point.x, point.y)
        # end
        # 
        # @coolbar.setLocked(true)
        # @coolbar.pack()
      end

      # def create_toolbar
      #   @toolbar = Swt::Widgets::ToolBar.new(composite, Swt::SWT::FLAT)
      #   @toolbar.set_visible(false)
      #   @toolbar
      # end
      
      def show
        # @toolbars.each_value { |toolbar| toolbar.set_visible(true) }
        @toolbar.set_visible(true)
      end

      def hide
        # @toolbars.each_value { |toolbar| toolbar.dispose() }
        @toolbar.dispose()
      end

      def close
        hide
        @result
      end

      def height
        return 0
        h = 0
        @toolbar.getItems.each do |i|
          h = ( h > i.getSize.y ) ? h : i.getSize.y
        end
        h
      end

      private

      def add_entries_to_toolbar(toolbar, toolbar_model)

        toolbar_model.each do |entry|
          if entry.is_a?(Redcar::ToolBar::LazyToolBar)
            toolbar_header = Swt::Widgets::ToolItem.new(toolbar, Swt::SWT::CASCADE)
            toolbar_header.text = entry.text
            #new_toolbar = Swt::Widgets::ToolBar.new(@window.shell, Swt::SWT::DROP_DOWN)
            new_toolbar = Swt::Widgets::ToolBar.new(toolbar)
            toolbar_header.toolbar = new_toolbar
            # toolbar_header.add_arm_listener do
            #   new_toolbar.get_items.each {|i| i.dispose }
            #   add_entries_to_toolbar(new_toolbar, entry)
            # end
          elsif entry.is_a?(Redcar::ToolBar)
            new_toolbar = Swt::Widgets::ToolBar.new(toolbar)
            add_entries_to_toolbar(new_toolbar, entry)
          elsif entry.is_a?(Redcar::ToolBar::Item::Separator)
            item = Swt::Widgets::ToolItem.new(toolbar, Swt::SWT::SEPARATOR)
          elsif entry.is_a?(Redcar::ToolBar::Item)
            item = Swt::Widgets::ToolItem.new(toolbar, Swt::SWT::PUSH)
            item.setEnabled(true)
            item.setImage(Swt::Graphics::Image.new(ApplicationSWT.display, ToolBar.icons[entry.icon] || entry.icon || DEFAULT_ICON ))
            connect_command_to_item(item, entry)
          else
            raise "unknown object of type #{entry.class} in toolbar"
          end
        end
        toolbar.pack
      end

      class SelectionListener
        def initialize(entry)
          @entry = entry
        end

        def widget_selected(e)
          @entry.selected(e.stateMask != 0)
        end

        def widget_default_selected(e)
          @entry.selected(e.stateMask != 0)
        end
      end

      def connect_command_to_item(item, entry)
        item.setToolTipText(entry.text)
        item.add_selection_listener(SelectionListener.new(entry))
        h = entry.command.add_listener(:active_changed) do |value|
          unless item.disposed
            item.enabled = value
          end
        end
        if not entry.command.active?
          item.enabled = false
        end
      end
    end
  end
end
