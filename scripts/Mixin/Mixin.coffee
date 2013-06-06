# Dynamic object composition helper. Most often used in an object's constructor
# function, however *instance* can be any object instance.
module.exports = (instance, Mixins...) ->
	
	# Each one of the mixins gets instantiated,
	for Mixin in Mixins
		mixin = new Mixin()
		
		# Then mixed in to the object we're extending.
		for own key of Mixin.prototype
			instance[key] = mixin[key]

	instance