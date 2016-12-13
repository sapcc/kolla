Other Build Systems
===================

Kolla can easily be integrated into other build-systems by rendering a configuration template with the options
``-t <config>.j2`` to a specific working directory (e.g ``-w <outputdir>``).
``<outputdir>`` will then contain the rendered configuration file for the build-system and in the sub-directories the various
Dockerfiles.

Examples
--------
Here are some examples, which are not considered to be complete examples, but just exemplary for the capabilities exposed.

Makefile
~~~~~~~~
Not the most sensible thing to do but a well known format.

::
	.PHONY: {%for image in images%}{{image.name}} {%endfor%}

	{%for image in images%}
	{{image.name}}: {{ image.path | replace(working_dir, '.') }}/Dockerfile{%if image.parent%} {{image.parent.name}}{%endif%}
			docker build {{ image.path | replace(working_dir, '.') }}
	{%endfor%}

For each image, create a target in its name, with the relative location of the Dockerfile and the optional parents name as a dependency.
The corresponding action is to call ``docker build`` with the corresponding relative path. Due to rendering, the action may be prefixed by spaces instead of a tab.


Concourse.yaml
~~~~~~~~~~~~~~
A slightly more complex (and non-working) example is Concourse.
It uses resources to specify the docker images, which build the docker images in the put operation.

::
	resources:
	{% for image in images %}
	   - name: {{ image.name }}-image
		 type: docker-image
		 source:
		   <<: *registry
		   repository: {{ namespace }}/{{ image_prefix }}{{image.name}}
	{% if image.source and image.source.type == 'git' %}
	   - name: {{ image.name }}-{{ image.source.type }}
		 type: {{ image.source.type }}
		 source:
		   uri: {{ image.source.source }}
		   branch: {{image.source.reference}}
	{% endif %}
	{% endfor %}

	jobs:
	{% for image in images %}
	  - name: {{ image.name }}
		plan:
	{% if image.parent %}
			- get: {{ image.parent.name }}-image
			  trigger: true
			  skip_download: true
			  passed: [{{ image.parent.name }}]
	{% endif %}
	{% if image.source and image.source.type == 'git' %}
			- get: {{ image.name }}-{{ image.source.type }}
			  trigger: true
	{% endif %}
		  - put: {{ image.name }}-image
			params:
			  build: {{ image.path | replace(working_dir, '.') }}
	{% endfor -%}

	{% raw %}
	source: &registry
		host:       {{registry-host}}
		email:      {{registry-email}}
		username:   {{registry-username}}
		password:   {{registry-password}}
	{% endraw %}


What is missing here is the step of rendering the Dockerfiles to a working-directory, and transporting the output through the pipeline.
