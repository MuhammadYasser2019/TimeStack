import React from "react"
import PropTypes from "prop-types"
import {isEmpty} from "../helpers/validator";
import BaseComponent from "./BaseComponent";
import {get_base_url} from "../helpers/requestHelper";

const axios = require('axios');

class CurrentUser extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            user_projects: []
        }
        this.get_user_projects = this.get_user_projects.bind(this);
    }

    get_user_projects() {
        axios.get(`${get_base_url()}/get_user_projects`).then(res=>{
            this.setState({ user_projects: res.data.result }) 
        });
    }

    componentDidMount() {
        this.get_user_projects();
    }


    render() {
        return (
            <BaseComponent>
                <i>Admin: {this.props.first_name + " " + this.props.last_name}</i>
                {this.state.user_projects && this.state.user_projects.length > 0 ? <div>
                    <b>Total Projects: {this.state.user_projects.length}</b>
                    {
                        this.state.user_projects.sort().map((project, index) => {
return <div key={`project_${index}`}>{`${index+1}. ${project}`}</div>
                        })}
                </div>
                    : null}
            </BaseComponent>
        );
    }
}

CurrentUser.propTypes = {
    first_name: PropTypes.string,
    last_name: PropTypes.string
};
export default CurrentUser
