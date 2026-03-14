# frozen_string_literal: true

require_relative 'lib/legion/extensions/salience/version'

Gem::Specification.new do |spec|
  spec.name          = 'legion-extensions-salience'
  spec.version       = Legion::Extensions::Salience::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Salience'
  spec.description   = 'Unified salience network for brain-modeled agentic AI — integrates signals from all cognitive subsystems'
  spec.homepage      = 'https://github.com/LegionIO/lex-salience'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']        = spec.homepage
  spec.metadata['source_code_uri']     = 'https://github.com/LegionIO/lex-salience'
  spec.metadata['documentation_uri']   = 'https://github.com/LegionIO/lex-salience'
  spec.metadata['changelog_uri']       = 'https://github.com/LegionIO/lex-salience'
  spec.metadata['bug_tracker_uri']     = 'https://github.com/LegionIO/lex-salience/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files         = Dir['lib/**/*']
  spec.require_paths = ['lib']
end
