package at.itbh.jira;


import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

@Path("/v0")
public class DemoEndpoint {

	@Inject
	private DemoBean bean;
	
	@GET
	@Path("/echo/{message}")
	public String echo(@PathParam("message") String message) {
		System.out.println("Message from Endpoint");
		return bean.echo(message);
	}
	
}
