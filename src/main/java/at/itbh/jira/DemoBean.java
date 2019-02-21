package at.itbh.jira;

import javax.annotation.security.RolesAllowed;
import javax.ejb.Stateless;

@Stateless
public class DemoBean {

	
	@RolesAllowed("rest")
	public String echo(String message) {
		System.out.println("Message from bean");
		return message;
	}
}
