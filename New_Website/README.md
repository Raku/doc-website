
# The Raku documentation suite built using Elucid8


<div id="General deployment"></div><div id="General_deployment"></div>

## General deployment
<span class="para" id="06c0096"></span>Obtain an container image by running *Podman* | *Docker* using `New_Website/Dockerfile`.   
  
&nbsp;&nbsp;• During the image generation, the document sources are pulled into the workspace from their repos;  
&nbsp;&nbsp;• the HTML files and other assets are generated  
&nbsp;&nbsp;• the HTML & assets are packaged with Caddy  
&nbsp;&nbsp;• a CMD is set so that caddy serves the HTML in answer to HTTP messages on :80  

<div id="Local deployment"></div><div id="Local_deployment"></div>

## Local deployment
<span class="para" id="2bbb53e"></span>Local deployment is intended for those who wish to contribute to this repository by modifying the index files in `site-sources` or the plugins in `local-lib`.   
  
&nbsp;&nbsp;• Clone the repo with `git clone https://github.com/raku/doc-website.git raku-doc-website`  
&nbsp;&nbsp;• Modify files in repo as need be  
&nbsp;&nbsp;• create image (see below)  
&nbsp;&nbsp;• run a container using image (see below)  
&nbsp;&nbsp;• inspect generated website by pointing browser at `localhost:3000`  
For local deployment, it is better to use a Cro app rather than Caddy.  
head2 Create image & run a container  
  
&nbsp;&nbsp;• assuming the current working directory in your local terminal is raku-doc-wehsite as cloned using git  
2.Create an image called RakuDocumentation by running *Podman* using `New_Website/LocalContainer.dockerfile`.  

<div id="Running the image as a container"></div><div id="Running_the_image_as_a_container"></div>

### Running the image as a container
Assuming the image is RakuDocumentation  

```
podman run --rm -d --name=rdw  --network=host RakuDocumentation
```
<span class="para" id="55de56d"></span>Point the browser to `localhost:3000`, which means that in the browser's URL window, type `localhost:3000`.   
Once inspecting is complete, the container will need to be removed, eg.  

```
podman stop rdw
```



----

----

Rendered from docs/README.rakudoc/README at 09:08 UTC on 2026-11-20

Source last modified at 09:05 UTC on 2026-11-20

