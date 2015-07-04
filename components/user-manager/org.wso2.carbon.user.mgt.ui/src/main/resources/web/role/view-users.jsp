<%--
  Copyright (c) 2010 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.

   WSO2 Inc. licenses this file to you under the Apache License,
   Version 2.0 (the "License"); you may not use this file except
   in compliance with the License.
   You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing,
   software distributed under the License is distributed on an
   "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
   KIND, either express or implied.  See the License for the
   specific language governing permissions and limitations
   under the License.
  --%>

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://wso2.org/projects/carbon/taglibs/carbontags.jar" prefix="carbon" %>
<%@page session="true" %>
<%@page import="org.apache.axis2.context.ConfigurationContext" %>
<%@page import="org.wso2.carbon.CarbonConstants" %>
<%@page import="org.wso2.carbon.ui.CarbonUIMessage" %>
<%@page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@page import="org.wso2.carbon.user.mgt.ui.UserAdminClient" %>
<%@page import="org.wso2.carbon.utils.ServerConstants" %>
<%@page import="java.net.URLEncoder" %>


<%@page import="org.wso2.carbon.ui.util.CharacterEncoder" %>
<%@ page import="org.wso2.carbon.user.mgt.ui.PaginatedNamesBean" %>
<%@ page import="org.wso2.carbon.user.mgt.ui.Util" %>
<%@ page import="org.wso2.carbon.user.mgt.stub.types.carbon.FlaggedName" %>
<%@ page import="org.wso2.carbon.user.mgt.ui.UserAdminUIConstants" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.MessageFormat" %>
<script type="text/javascript" src="../userstore/extensions/js/vui.js"></script>
<script type="text/javascript" src="../admin/js/main.js"></script>
<jsp:include page="../dialog/display_messages.jsp"/>
<jsp:include page="../userstore/display-messages.jsp"/>

<%
    String BUNDLE = "org.wso2.carbon.userstore.ui.i18n.Resources";
    ResourceBundle resourceBundle = ResourceBundle.getBundle(BUNDLE, request.getLocale());

    boolean newFilter = false;
    boolean doUserList = true;
    boolean readOnlyRole = false;
    boolean showFilterMessage = false;
    boolean showUpdate = true;
    List<FlaggedName> dataList = null;
    FlaggedName exceededDomains = null;
    FlaggedName[] users = null;
    int pageNumber = 0;
    int cachePages = 3;
    int noOfPageLinksToDisplay = 5;
    int numberOfPages = 0;
    Map<Integer, PaginatedNamesBean>  flaggedNameMap = null;
    if(request.getParameter("pageNumber") == null){
        session.removeAttribute("checkedUsersMap");
    }
    if(session.getAttribute("checkedUsersMap") == null){
        session.setAttribute("checkedUsersMap",new HashMap<String,Boolean>());
    }

    // find out jsp to send back
    String prevPage = request.getParameter("prevPage");
    String prevUser = request.getParameter("prevUser");
    String prevPageNumber = request.getParameter("prevPageNumber");
    String prevString = null;


    if(prevPage != null && prevPage.trim().length() > 0 && prevUser !=null &&  prevUser.trim().length() > 0){
        showUpdate = false;
        if("view".equals(prevPage)){
            prevString = "../user/view-roles.jsp?username="+URLEncoder.encode(prevUser) + "&pageNumber=" + prevPageNumber;
        }else if("edit".equals(prevPage)){
            prevString = "../user/edit-user-roles.jsp?username="+URLEncoder.encode(prevUser) + "&pageNumber=" + prevPageNumber;
        }
        session.setAttribute("prevString", prevString);
    } else {
        prevString = (String)session.getAttribute("prevString");
        if(prevString != null){
            showUpdate = false;
        }
    }

%>
    <script type="text/javascript">
        function doCancel() {
            <%
             if(showUpdate){
                prevString = "role-mgt.jsp";
             }
            %>
            location.href = '<%=prevString%>';
        }
    </script>
<%
	// search filter
    String filter = request.getParameter(UserAdminUIConstants.ROLE_LIST_VIEW_USER_FILTER);
    if (filter == null || filter.trim().length() == 0) {
        filter = (java.lang.String) session.getAttribute(UserAdminUIConstants.ROLE_LIST_VIEW_USER_FILTER);
        if (filter == null || filter.trim().length() == 0) {
            filter = "*";
        }
    } else {
        newFilter = true;
    }
    
    filter = filter.trim();
    session.setAttribute(UserAdminUIConstants.ROLE_LIST_VIEW_USER_FILTER, filter);

    String roleName = CharacterEncoder.getSafeText(request.getParameter("roleName"));

	String readOnlyRoleString = request.getParameter(UserAdminUIConstants.ROLE_READ_ONLY);
	if (readOnlyRoleString == null) {
		readOnlyRoleString =
		                     (String) session.getAttribute(UserAdminUIConstants.ROLE_READ_ONLY);
	}
	if ("true".equals(readOnlyRoleString)) {
		readOnlyRole = true;
	}

	exceededDomains =
	                  (FlaggedName) session.getAttribute(UserAdminUIConstants.ROLE_LIST_ASSIGNED_USER_CACHE_EXCEEDED);

	// check page number
	String pageNumberStr = request.getParameter("pageNumber");
	if (pageNumberStr == null) {
		pageNumberStr = "0";
	}

	try {
		pageNumber = Integer.parseInt(pageNumberStr);
	} catch (NumberFormatException ignored) {
		// page number format exception
	}

	flaggedNameMap =
	                 (Map<Integer, PaginatedNamesBean>) session.getAttribute(UserAdminUIConstants.ROLE_LIST_ASSIGNED_USER_CACHE);
	if (flaggedNameMap != null) {
		PaginatedNamesBean bean = flaggedNameMap.get(pageNumber);
		if (bean != null) {
			users = bean.getNames();
			if (users != null && users.length > 0) {
				numberOfPages = bean.getNumberOfPages();
				doUserList = false;
			}
		}
	}

	if (doUserList || newFilter) {
		try {
			String cookie =
			                (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);
			String backendServerURL =
			                          CarbonUIUtil.getServerURL(config.getServletContext(),
			                                                    session);
			ConfigurationContext configContext =
			                                     (ConfigurationContext) config.getServletContext()
			                                                                  .getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);
			UserAdminClient client =
			                         new UserAdminClient(cookie, backendServerURL,
			                                             configContext);
			if (filter.length() > 0) {
				FlaggedName[] data = client.getUsersOfRole(roleName, filter, 0);
				dataList = new ArrayList<FlaggedName>(Arrays.asList(data));
				exceededDomains = dataList.remove(dataList.size() - 1);
				session.setAttribute(UserAdminUIConstants.ROLE_LIST_ASSIGNED_USER_CACHE_EXCEEDED,
				                     exceededDomains);
				if (dataList != null && dataList.size() > 0) {
					flaggedNameMap = new HashMap<Integer, PaginatedNamesBean>();
					int max = pageNumber + cachePages;
					for (int i = (pageNumber - cachePages); i < max; i++) {
						if (i < 0) {
							max++;
							continue;
						}
						PaginatedNamesBean bean =
						                          Util.retrievePaginatedFlaggedName(i,
						                                                            dataList);
						flaggedNameMap.put(i, bean);
						if (bean.getNumberOfPages() == i + 1) {
							break;
						}
					}
					users = flaggedNameMap.get(pageNumber).getNames();
					numberOfPages = flaggedNameMap.get(pageNumber).getNumberOfPages();
					session.setAttribute(UserAdminUIConstants.ROLE_LIST_ASSIGNED_USER_CACHE,
					                     flaggedNameMap);
				} else {
					session.removeAttribute(UserAdminUIConstants.ROLE_LIST_VIEW_USER_FILTER);
					showFilterMessage = true;
				}
			}
		} catch (Exception e) {
            String message = MessageFormat.format(resourceBundle.getString("error.while.loading.users.of"),
                    CharacterEncoder.getSafeText(roleName),e.getMessage());
%>
<script type="text/javascript">
    jQuery(document).ready(function () {
        CARBON.showErrorDialog('<%=message%>',  function () {
            location.href = "role-mgt.jsp";
        });
    });
</script>
<%
        }
    }
    Util.updateCheckboxStateMap((Map<String,Boolean>)session.getAttribute("checkedUsersMap"),flaggedNameMap,
            request.getParameter("selectedUsers"),request.getParameter("unselectedUsers"),":");
%>
<fmt:bundle basename="org.wso2.carbon.userstore.ui.i18n.Resources">
<carbon:breadcrumb label="users.in.the.role"
                   resourceBundle="org.wso2.carbon.userstore.ui.i18n.Resources"
                   topPage="true" request="<%=request%>"/>

<script type="text/javascript">

    function doValidation() {
        return true;
    }

    function doUpdate() {
        document.edit_users.submit();
    }

    function doFinish() {

        document.edit_users.finish.value = 'true';
        document.edit_users.submit();
    }

    function doPaginate(page, pageNumberParameterName, pageNumber){
        var form = document.createElement("form");
        form.setAttribute("method", "POST");
        form.setAttribute("action", page + "?" + pageNumberParameterName + "=" + pageNumber + "&roleName=" + '<%=roleName%>');
        var selectedRolesStr = "";
        $("input:checkbox:checked").each(function(index){
            if(!$(this).is(":disabled")){
                selectedRolesStr += $(this).val();
                if(index != $("input:checkbox:checked").length-1){
                    selectedRolesStr += ":";
                }
            }
        });
        var selectedRolesElem = document.createElement("input");
        selectedRolesElem.setAttribute("type", "hidden");
        selectedRolesElem.setAttribute("name", "selectedUsers");
        selectedRolesElem.setAttribute("value", selectedRolesStr);
        form.appendChild(selectedRolesElem);
        var unselectedRolesStr = "";
        $("input:checkbox:not(:checked)").each(function(index){
            if(!$(this).is(":disabled")){
                unselectedRolesStr += $(this).val();
                if(index != $("input:checkbox:not(:checked)").length-1){
                    unselectedRolesStr += ":";
                }
            }
        });
        var unselectedRolesElem = document.createElement("input");
        unselectedRolesElem.setAttribute("type", "hidden");
        unselectedRolesElem.setAttribute("name", "unselectedUsers");
        unselectedRolesElem.setAttribute("value", unselectedRolesStr);
        form.appendChild(unselectedRolesElem);
        document.body.appendChild(form);
        form.submit();
    }

    function doSelectAllRetrieved() {
        var form = document.createElement("form");
        form.setAttribute("method", "POST");
        form.setAttribute("action", "view-users.jsp?pageNumber=" + <%=pageNumber%> + "&roleName=" + '<%=roleName%>');
        var selectedRolesElem = document.createElement("input");
        selectedRolesElem.setAttribute("type", "hidden");
        selectedRolesElem.setAttribute("name", "selectedUsers");
        selectedRolesElem.setAttribute("value", "ALL");
        form.appendChild(selectedRolesElem);
        document.body.appendChild(form);
        form.submit();

    }

    function doUnSelectAllRetrieved() {
        var form = document.createElement("form");
        form.setAttribute("method", "POST");
        form.setAttribute("action", "view-users.jsp?pageNumber=" + <%=pageNumber%> + "&roleName=" + '<%=roleName%>');
        var unselectedRolesElem = document.createElement("input");
        unselectedRolesElem.setAttribute("type", "hidden");
        unselectedRolesElem.setAttribute("name", "unselectedUsers");
        unselectedRolesElem.setAttribute("value", "ALL");
        form.appendChild(unselectedRolesElem);
        document.body.appendChild(form);
        form.submit();
    }

</script>


<div id="middle">
    <h2><fmt:message key="users.list.in.role"/> <%=roleName%>
    </h2>

    <script type="text/javascript">

        <%if(showFilterMessage == true){%>
        CARBON.showInfoDialog('<fmt:message key="no.users.filtered"/>', null, null);
        <%}%>

    </script>
    <div id="workArea">
        <form name="filterForm" method="post" action="view-users.jsp">
        	<input type="hidden" name="roleName" value="<%=roleName %>" />
            <table class="normal">
                <tr>
                    <td><fmt:message key="list.users"/></td>
                    <td>
                        <input type="text" name="<%=UserAdminUIConstants.ROLE_LIST_VIEW_USER_FILTER%>"
                               value="<%=filter%>"/>
                    </td>
                    <td>
                        <input class="button" type="submit"
                               value="<fmt:message key="user.search"/>"/>
                    </td>
                </tr>
            </table>
        </form>
        <p>&nbsp;</p>

        <carbon:paginator pageNumber="<%=pageNumber%>"
                          action="post"
                          numberOfPages="<%=numberOfPages%>"
                          noOfPageLinksToDisplay="<%=noOfPageLinksToDisplay%>"
                          page="view-users.jsp" pageNumberParameterName="pageNumber"
                          parameters="<%="roleName="+roleName%>"/>
        <form method="post" action="edit-users-finish.jsp?viewUsers=true" onsubmit="return doValidation();"
              name="edit_users" id="edit_users">
            <input type="hidden" id="roleName" name="roleName" value="<%=roleName%>"/>
            <input type="hidden" id="logout" name="logout" value="false"/>
            <input type="hidden" id="finish" name="finish" value="false"/>

            <table class="styledLeft" id="table_users_list_of_role">


                <thead>
                <tr>
                    <th><fmt:message key="users.in.the.role"/></th>
                </tr>
                </thead>

                <tbody>
                <%if(users != null && users.length > 0 && showUpdate){%>
                    <tr>
                        <td colspan="4">

                            <%
                                String fromPage = "1";
                                String toPage = String.valueOf(numberOfPages);
                                if(pageNumber - cachePages >= 0){
                                    fromPage = String.valueOf(pageNumber + 1 - cachePages);
                                }
                                if(pageNumber + cachePages <= numberOfPages-1){
                                    toPage = String.valueOf(pageNumber + 1 + cachePages);
                                }
                            %>

                            <a href="#" onclick="doSelectAll('selectedUsers');"/>
                                <fmt:message key="select.all.page"/> </a> |
                            <a href="#" onclick="doUnSelectAll('selectedUsers');"/>
                                <fmt:message key="unselect.all.page"/> </a>
                            <%if(Integer.parseInt(fromPage) < Integer.parseInt(toPage)){%>
                                | <a href="#" onclick="doSelectAllRetrieved();"/>
                                    <fmt:message key="select.all.page.from"/> <%=fromPage%> <fmt:message key="select.all.page.to"/> <%=toPage%></a> |
                                <a href="#" onclick="doUnSelectAllRetrieved();"/>
                                    <fmt:message key="unselect.all.page.from"/> <%=fromPage%> <fmt:message key="unselect.all.page.to"/> <%=toPage%></a>
                            <%}%>
                        </td>
                    </tr>
                <% } %>
                <tr>
                    <td colspan="2">
                        <%
                            if (users != null) {
                                for (FlaggedName user : users) {
                                    if (user != null) {
                                        String doCheck = "checked=\"checked\"";
                                        String doEdit = "";
                                        if (user.getItemName().equals(CarbonConstants.REGISTRY_ANONNYMOUS_USERNAME)) {
                                            continue;
                                        } else if(readOnlyRole && !user.getEditable()){
                                            doEdit = "disabled=\"disabled\"";
                                        } else if(session.getAttribute("checkedUsersMap") != null &&
                                                ((Map<String, Boolean>) session.getAttribute("checkedUsersMap")).get(user.getItemName()) != null &&
                                                ((Map<String, Boolean>) session.getAttribute("checkedUsersMap")).get(user.getItemName()) == false){
                                            doCheck = "";
                                        }

                                        String userName = CharacterEncoder.getSafeText(user.getItemName());
                                        String displayName = CharacterEncoder.getSafeText(user.getItemDisplayName());
                                        if (displayName == null || displayName.trim().length() == 0) {
                                            displayName = userName;
                                        }
                        %>

                        <% if(showUpdate) {%>
                            <input type="checkbox" name="selectedUsers" value="<%=userName%>" <%=doCheck%> <%=doEdit%> />
                        <% } %>
                        <%=displayName%>
                        <input type="hidden" name="shownUsers" value="<%=userName%>"/><br/>
                        <%
                                    }
                                }
                            }

                        %>
                    </td>
                </tr>
                </tbody>
            </table>                
                <carbon:paginator pageNumber="<%=pageNumber%>"
                                  action="post"
                                  numberOfPages="<%=numberOfPages%>"
                                  noOfPageLinksToDisplay="<%=noOfPageLinksToDisplay%>"
                                  page="view-users.jsp" pageNumberParameterName="pageNumber"
                                  parameters="<%="roleName="+roleName%>"/>
            <%
                if (users != null && users.length > 0 && exceededDomains != null) {
                    if(exceededDomains.getItemName() != null || exceededDomains.getItemDisplayName() != null){
                        String message = null;
                        if(exceededDomains.getItemName() != null && exceededDomains.getItemName().equals("true")){
                            if(exceededDomains.getItemDisplayName() != null && !exceededDomains.getItemDisplayName().equals("")){
                                String arg = "";
                                String[] domains = exceededDomains.getItemDisplayName().split(":");
                                for(int i=0;i<domains.length;i++){
                                    arg += "\'"+domains[i]+"\'";
                                    if(i < domains.length - 2){
                                        arg += ", ";
                                    }else if(i == domains.length - 2){
                                        arg += " and ";
                                    }
                                }
                                message = resourceBundle.getString("more.users.others").replace("{0}",arg);
                            } else{
                                message = resourceBundle.getString("more.users.primary");
                            }
        %>
        <strong><%=message%></strong>
        <%
        }else if(exceededDomains.getItemDisplayName() != null && !exceededDomains.getItemDisplayName().equals("")){
            String[] domains = exceededDomains.getItemDisplayName().split(":");
            String arg = "";
            for(int i=0;i<domains.length;i++){
                arg += "\'"+domains[i]+"\'";
                if(i < domains.length - 2){
                    arg += ", ";
                }else if(i == domains.length - 2){
                    arg += " and ";
                }
            }
            message = resourceBundle.getString("more.users").replace("{0}",arg);
        %>
        <strong><%=message%></strong>
        <%
                        }
                    }
                }
            %>

                <tr>
                    <td class="buttonRow">
                        <%
                            if(showUpdate && !readOnlyRole && !showFilterMessage){
                        %>
                                <input class="button" type="button" value="<fmt:message key="update"/>" onclick="doUpdate()"/>
                                <input class="button" type="button" value="<fmt:message key="finish"/>" onclick="doFinish()"/>
                        <%
                            }
                        %>
                            <input class="button" type="button" value="<fmt:message key="cancel"/>" onclick="doCancel()"/>
                    </td>
                </tr>
        </form>
    </div>
</div>
</fmt:bundle>
