module BootstrapHelper
	class BootstrapFormBuilder < ActionView::Helpers::FormBuilder
		def toggle_button(method, name, options={}, &block)
			state = options.delete(:state)
			toggled = object.send(method)

			options[:class] ||= ''
			options[:class] << ' btn-toggle'
			options[:class] << ' active' if toggled == state

			options[:value] ||= state ? '1' : '0'

			options[:data] ||= {}
			options[:data].reverse_merge!(hidden_field: "\##{object_name}_#{method}")

			button(name, options)
		end
	end
end
